Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin
Imports DI.PortalAdmin.Data

Public Class NoteAnamnesticheLista
    Inherits System.Web.UI.Page

#Region "Property di pagina"
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

    Private gvCancelSelect = True
#End Region

    Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
        Try
            '
            'Setta il pulsante di default.
            '
            Me.Form.DefaultButton = Me.SearchButton.UniqueID
            If Not Page.IsPostBack Then
                '
                'Ricarica i filtri prendendoli dalla sessione.
                '
                FilterHelper.Restore(filterPanel, msPAGEKEY)
                '
                'Se l'azienda è valorizzata allora carica i sistemi.
                '
                If ddlAzienda.SelectedValue.Trim <> String.Empty Then
                    '
                    'Se nei filtri salvati trovoa l'azienda, carico la sua lista sistemi eroganti
                    '
                    'ddlSistema.DataBind()
                    loadDropDownListSistemi()

                    '
                    'Ripeto il caricamento del contenuto della dropdown
                    '
                    FilterHelper.Restore(ddlSistema, msPAGEKEY)
                End If

                '
                ' Setto a FALSE gvCancelSelect in modo da NON eseguire la select dell'object data source.
                '
                gvCancelSelect = True
                'gvCancelSelect = False
                'gvNoteAnamnestiche.DataBind()
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

#Region "ObjectDataSource"
    Private Sub odsNoteAnamnestiche_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsNoteAnamnestiche.Selected
        '
        'Gestisco eventuali errori.
        '
        GestioneErrori.ObjectDataSource_TrapError(e, lblError)
    End Sub

    Private Sub odsNoteAnamnestiche_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsNoteAnamnestiche.Selecting
        Try
            '
            'Cancello la query se gvCancelSelect è true.
            '
            If gvCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If

            '
            'Se sono qui i filtri sono stati impostati correttamente.
            '
            If Not String.IsNullOrEmpty(txtIdNota.Text) Then
                e.InputParameters("IdNotaAnamnestica") = New Guid(txtIdNota.Text)
            End If

            If Not String.IsNullOrEmpty(txtIdEsterno.Text) Then
                e.InputParameters("IdEsterno") = txtIdEsterno.Text
            End If

            If Not String.IsNullOrEmpty(txtIdPaziente.Text) Then
                e.InputParameters("IdPaziente") = txtIdPaziente.Text
            End If

            '
            'Verifico che il campo sia valorizzato.
            '
            If Not String.IsNullOrEmpty(txtDataModificaDal.Text) Then
                e.InputParameters("DataModificaDAL") = CType(txtDataModificaDal.Text, DateTime)
            End If

            Dim dDataModificaAl As DateTime = DateTime.Now
            If Not String.IsNullOrEmpty(txtDataModificaAl.Text) Then
                dDataModificaAl = CType(txtDataModificaAl.Text, DateTime)
            End If
            e.InputParameters("DataModificaAL") = dDataModificaAl

            e.InputParameters("AziendaErogante") = ddlAzienda.SelectedValue
            e.InputParameters("SistemaErogante") = ddlSistema.SelectedValue

            '
            'Verifico che il campo sia valorizzato.
            '
            If Not String.IsNullOrEmpty(txtDataNota.Text) Then
                e.InputParameters("DataNota") = CType(txtDataNota.Text, DateTime)
            End If

            '
            'Verifico che il campo sia valorizzato.
            '
            If Not String.IsNullOrEmpty(txtDataNascita.Text) Then
                e.InputParameters("DataNascita") = CType(txtDataNascita.Text, DateTime)
            End If

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub
#End Region

#Region "Filtri"
    Private Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
        Try
            '
            'Eseguo il bind dei dati solo se i filtri impostati sono validi.
            '
            If ValidateFilters() Then
                '
                'Salvo i filtri in sessione.
                '
                FilterHelper.SaveInSession(filterPanel, msPAGEKEY)

                '
                'Imposto a false la variabile gvCancelSelect in modo da eseguire la query dell'ObjectDataSource.
                '
                gvCancelSelect = False

                '
                'Eseguo il bind dei dati.
                '
                gvNoteAnamnestiche.DataBind()

                '
                '2020-07-03 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Ricercate note anamnestiche", filterPanel, Nothing)

            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    ''' <summary>
    ''' Verifica se i valori dei filtri sono impostati correttamente.
    ''' </summary>
    ''' <returns></returns>
    Private Function ValidateFilters() As Boolean
        Dim result As Boolean = True

        '
        'Una tra le seguenti combinazioni deve essere valorizzata
        '   1) IdEsterno
        '   2) IdNota
        '   3) IdPaziente
        '   4) Azienda + Sistema + (DataModificaDal o DataNota)
        '
        If String.IsNullOrEmpty(txtIdPaziente.Text) AndAlso String.IsNullOrEmpty(txtIdEsterno.Text) AndAlso String.IsNullOrEmpty(txtIdNota.Text) AndAlso (String.IsNullOrEmpty(ddlAzienda.SelectedValue) OrElse String.IsNullOrEmpty(ddlSistema.SelectedValue) OrElse (String.IsNullOrEmpty(txtDataModificaDal.Text) AndAlso String.IsNullOrEmpty(txtDataNota.Text))) Then
            Utility.ShowErrorLabel(lblError, "Per effettuare la ricerca compilare una delle combinazioni di filtri come indicato.")
            result = False
        End If

        '
        'Controllo se il campo idpaziente contiene un guid valido.
        '
        If Not String.IsNullOrEmpty(txtIdPaziente.Text) AndAlso Not Utility.SQLTypes.IsValidGuid(txtIdPaziente.Text) Then
            Utility.ShowErrorLabel(lblError, "Il campo Id Paziente non contiene un GUID valido.")
            result = False
        End If

        '
        'Controllo se il campo idpaziente contiene un guid valido.
        '
        If Not String.IsNullOrEmpty(txtIdNota.Text) AndAlso Not Utility.SQLTypes.IsValidGuid(txtIdNota.Text) Then
            Utility.ShowErrorLabel(lblError, "Il campo Id Nota non contiene un GUID valido.")
            result = False
        End If

        '
        'Verifico se è una data valida.
        '
        If Not String.IsNullOrEmpty(txtDataModificaAl.Text) AndAlso Not Utility.SQLTypes.IsValidDateTime(txtDataModificaAl.Text) Then
            Utility.ShowErrorLabel(lblError, "Il campo 'Data Modifica Al' non contiene una data valida.")
            result = False
        End If

        '
        'Verifico se è una data valida.
        '
        If Not String.IsNullOrEmpty(txtDataModificaDal.Text) AndAlso Not Utility.SQLTypes.IsValidDateTime(txtDataModificaDal.Text) Then
            Utility.ShowErrorLabel(lblError, "Il campo 'Data Modifica Dal' non contiene una data valida.")
            result = False
        End If

        '
        'Verifico se è una data valida.
        '
        If Not String.IsNullOrEmpty(txtDataNota.Text) AndAlso Not Utility.SQLTypes.IsValidDateTime(txtDataNota.Text) Then
            Utility.ShowErrorLabel(lblError, "Il campo 'Data Nota' non contiene una data valida.")
            result = False
        End If

        '
        'Verifico se è una data valida.
        '
        If Not String.IsNullOrEmpty(txtDataNascita.Text) AndAlso Not Utility.SQLTypes.IsValidDateTime(txtDataNascita.Text) Then
            Utility.ShowErrorLabel(lblError, "Il campo 'Data Nota' non contiene una data valida.")
            result = False
        End If

        Return result
    End Function

    Private Sub ddlAzienda_DataBound(sender As Object, e As System.EventArgs) Handles ddlAzienda.DataBound
        '
        'Inserisce un item vuoto nella dropdownlist delle aziende.
        '
        ddlAzienda.Items.Insert(0, "")
    End Sub

    Private Sub ddlSistema_DataBound(sender As Object, e As System.EventArgs) Handles ddlSistema.DataBound
        '
        'Inserisce un item vuoto nella dropdownlist dei sistemi.
        '
        ddlSistema.Items.Insert(0, "")
    End Sub

    Protected Sub ClearFiltersButton_Click(sender As Object, e As EventArgs) Handles ClearFiltersButton.Click
        Try
            FilterHelper.Clear(filterPanel, msPAGEKEY)
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub
#End Region

#Region "Eventi_GridView"
    Private Sub gvNoteAnamnestiche_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvNoteAnamnestiche.RowCommand
        Try
            '
            ' Ottengo l'index della row per ottenere l'ID e la Data di partizione della nota anamnestica
            ' tramite le DataKeys della gridView.
            '
            Dim rowIndex As Integer = e.CommandArgument
            Dim gID As Guid = gvNoteAnamnestiche.DataKeys(rowIndex).Values("Id")
            Dim dDataPartizione As DateTime = CType(gvNoteAnamnestiche.DataKeys(rowIndex).Values("DataPartizione"), DateTime)

            If e.CommandName.ToUpper = "RINOTIFICANOTA" Then
                '
                'Eseguo la rinotifica della Nota Anamnestica
                '
                Using ta As New NoteAnamnesticheDataSetTableAdapters.QueriesTableAdapter
                    ta.NoteAnamnesticheNotificaById(gID, dDataPartizione)
                End Using
                '
                ' Mostro alert di rinotifica accodata.
                '
                Page.ClientScript.RegisterStartupScript(Me.GetType, "msg", "alert('Notifica accodata.');", True)

            ElseIf e.CommandName.ToUpper = "FINEVALIDITANOTA" Then
                Dim sTipoCancellazione = "FINE_VALIDITA"
                Using ta As New NoteAnamnesticheDataSetTableAdapters.QueriesTableAdapter
                    ta.NotaAnamnesticaCancella(gID, dDataPartizione, sTipoCancellazione)
                End Using
                '
                ' Mostro alert di ANNULLAMENTO
                '
                Page.ClientScript.RegisterStartupScript(Me.GetType, "msg", "alert('La nota è stata INVALIDATA.');", True)
                '
                ' Rieseguo query di ricerca
                '
                gvCancelSelect = False
                gvNoteAnamnestiche.DataBind()

                '
                '2020-07-07 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Invalidata nota anamnestica", idPaziente:=Nothing, Nothing, gID.ToString(), "Id nota anamnestica")



            ElseIf e.CommandName.ToUpper = "CANCELLANOTA" Then
                Dim sTipoCancellazione = "FISICA"
                Using ta As New NoteAnamnesticheDataSetTableAdapters.QueriesTableAdapter
                    ta.NotaAnamnesticaCancella(gID, dDataPartizione, sTipoCancellazione)
                End Using
                '
                ' Mostro alert di CANCELLAZIONE
                '
                Page.ClientScript.RegisterStartupScript(Me.GetType, "msg", "alert('La nota è stata CANCELLATA.');", True)
                '
                ' Rieseguo query di ricerca
                '
                gvCancelSelect = False
                gvNoteAnamnestiche.DataBind()

                '
                '2020-07-07 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Cancellata nota anamnestica", idPaziente:=Nothing, Nothing, gID.ToString(), "Id nota anamnestica")


            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub
#End Region


#Region "Funzioni usate nel markup"

    'Protected Function AnnullaNotaVisible(ByVal oStatoCodice As Object) As Boolean
    '    Dim iStatoCodice As Integer = CType(oStatoCodice, Integer)
    '    '
    '    ' 3= Annullato
    '    '
    '    Return iStatoCodice <> 3
    'End Function

#End Region

    Private Sub ddlAzienda_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlAzienda.SelectedIndexChanged
        Try
            loadDropDownListSistemi()
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub


    ''' <summary>
    ''' Funzione che si occupa del caricamento della dropdownlist dei sistemi in base al valore selezionato di ddlAzienda.
    ''' </summary>
    Private Sub loadDropDownListSistemi()
        Try
            If Not String.IsNullOrEmpty(ddlAzienda.SelectedValue) Then
                ' Eseguo query per popolare ddlSistema
                Dim dt As DI.DataWarehouse.Admin.Data.BackEndDataSet.SistemiErogantiListaDataTable = Nothing
                Using ta As New DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SistemiErogantiListaTableAdapter
                    dt = ta.GetDataByAziendaETipo(ddlAzienda.SelectedValue, "NoteAnamnestiche")
                End Using
                'Cancello gli item presenti
                ddlSistema.Items.Clear()
                'Eseguo bind
                ddlSistema.DataSource = dt
                ddlSistema.DataTextField = "Descrizione"
                ddlSistema.DataValueField = "Codice"
                ddlSistema.DataBind()
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub gvNoteAnamnestiche_Sorting(sender As Object, e As GridViewSortEventArgs) Handles gvNoteAnamnestiche.Sorting
        Try
            'Permetto il bind dei dati.
            gvCancelSelect = False
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub
End Class