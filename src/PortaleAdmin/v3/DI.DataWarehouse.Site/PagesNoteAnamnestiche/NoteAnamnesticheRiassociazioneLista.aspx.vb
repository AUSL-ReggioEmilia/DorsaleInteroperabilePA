Imports System
Imports System.Data
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin
Imports DI.PortalAdmin.Data

Public Class NoteAnamnesticheRiassociazioneLista
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
                    ''ddlSistema.DataBind()
                    'MODIFICA ETTORE: 2018-06/19
                    Call LoadComboSistemi()

                    '
                    'Ripeto il caricamento del contenuto della dropdown
                    '
                    FilterHelper.Restore(ddlSistema, msPAGEKEY)

                End If

                '
                'setto a true gvCancelSelect in modo da eseguire la select dell'object data source.
                '
                gvCancelSelect = False
                gvLista.DataBind()
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub chkNoteOrfane_CheckedChanged(sender As Object, e As EventArgs) Handles chkNoteOrfane.CheckedChanged
        Try
            Dim chk As CheckBox = CType(sender, CheckBox)
            txtIdPaziente.Enabled = chk.Checked
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

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
                gvLista.DataBind()

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

#End Region

#Region "ObjectDataSource"
    Private Sub odsLista_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
        '
        'Gestisco eventuali errori.
        '
        GestioneErrori.ObjectDataSource_TrapError(e, lblError)
    End Sub

    Private Sub odsLista_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
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
                e.InputParameters("IdNota") = New Guid(txtIdNota.Text)
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
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub
#End Region

#Region "FunzioniMarkup"
    Protected Function GetHTML_Paziente(ByVal obj As DataRowView) As String
        Dim oRow As NoteAnamnesticheDataSet.NoteAnamnesticheRiassociazioneListaRow = CType(obj.Row, NoteAnamnesticheDataSet.NoteAnamnesticheRiassociazioneListaRow)
        Try
            Dim str As String = String.Concat("<b>", Utility.IsNull(oRow.Nome, ""), " ", Utility.IsNull(oRow.Cognome, ""), "</b>")

            If Not oRow.IsDataNascitaNull Then
                str = String.Concat(str, "<br/>Nato&nbsp;")
            End If
            If Not oRow.IsComuneNascitaNull Then
                str = String.Concat(str, "a:&nbsp;", oRow.ComuneNascita)
            End If
            If Not oRow.IsProvinciaNascitaNull Then
                str = String.Concat(str, "&nbsp;(", oRow.ProvinciaNascita, ")")
            End If
            If Not oRow.IsComuneNascitaNull OrElse Not oRow.IsProvinciaNascitaNull Then
                str = String.Concat(str, "<br/>")
            End If
            If Not oRow.IsDataNascitaNull Then
                str = String.Concat(str, "il:&nbsp;", oRow.DataNascita.ToShortDateString())
            End If
            If Not oRow.IsCodiceFiscaleNull Then
                str = String.Concat(str, "<br/>C.F.:&nbsp;", oRow.CodiceFiscale)
            End If
            If Not oRow.IsSACProvenienzaNull Then
                str = String.Concat(str, "<br/>Provenienza:&nbsp;", oRow.SACProvenienza)
                If Not oRow.IsSACIdProvenienzaNull Then
                    str = String.Concat(str, "(", oRow.SACIdProvenienza, ")")
                End If
            End If

            Return str
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
            Return String.Concat("<b>", Utility.IsNull(oRow.Nome, "-"), " ", Utility.IsNull(oRow.Cognome, "-"), "</b>")
        End Try
    End Function

    Private Sub gvLista_PreRender(sender As Object, e As EventArgs) Handles gvLista.PreRender
        '
        'Nascondo la colonna dati anadrafici sac se si vogliono vedere solo i referti orfani
        '
        Try
            For Each col As DataControlField In gvLista.Columns
                If col.HeaderText = "Dati anagrafici SAC" Then
                    col.Visible = Not chkNoteOrfane.Checked
                    Exit For
                End If
            Next
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub ddlAzienda_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlAzienda.SelectedIndexChanged
        Try
            If Not String.IsNullOrEmpty(ddlAzienda.SelectedValue) Then
                ' Eseguo query per popolare ddlSistema
                ' MODIFICA ETTORE: 2018-06/19
                Call LoadComboSistemi()
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    ''' <summary>
    ''' 'MODIFICA ETTORE: 2018-06/19
    ''' </summary>
    Private Sub LoadComboSistemi()
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
    End Sub

#End Region

End Class