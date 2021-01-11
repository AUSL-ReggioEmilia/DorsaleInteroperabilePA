Imports System
Imports System.Data
Imports System.Web
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin
Imports DI.PortalAdmin.Data

Public Class RicoveriLista
    Inherits System.Web.UI.Page

    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
    Dim btnSearchClicked As Boolean = False


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        RicoveriGridView.EmptyDataText = ""
        Me.Form.DefaultButton = Me.SearchButton.UniqueID
        If Not Page.IsPostBack Then
            '
            'Ricarico i filtri salvati in sessione
            '
            FilterHelper.Restore(filterPanel, msPAGEKEY)
        End If
    End Sub

    Private Sub SearchButton_Click(sender As Object, e As System.EventArgs) Handles SearchButton.Click
        Try
            btnSearchClicked = True
            FilterHelper.SaveInSession(filterPanel, msPAGEKEY)
            RicoveriGridView.EmptyDataText = "Nessun risultato!"
            If ValidateFilters() Then
                RicoveriGridView.DataBind()

                '
                '2020-07-03 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Ricerca ricovero", filterPanel, Nothing)

            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Function ValidateFilters() As Boolean
        Dim result As Boolean = True



        'If String.IsNullOrEmpty(txtCodiceFiscale.Text) AndAlso String.IsNullOrEmpty(txtCognome.Text) AndAlso
        '    String.IsNullOrEmpty(txtNome.Text) AndAlso String.IsNullOrEmpty(txtDataNascita.Text) AndAlso String.IsNullOrEmpty(txtNumeroNosologico.Text) AndAlso
        '    String.IsNullOrEmpty(TxtRicovero.Text) Then
        '    If btnSearchClicked Then
        '        Utility.ShowErrorLabel(LabelError, "Per effettuare la ricerca compilare una delle combinazioni di filtri come indicato.")
        '    End If
        '    result = False
        'End If

        If String.IsNullOrEmpty(txtIdPaziente.Text) AndAlso String.IsNullOrEmpty(TxtRicovero.Text) AndAlso (String.IsNullOrEmpty(txtNumeroNosologico.Text) OrElse String.IsNullOrEmpty(cmbAzienda.SelectedValue)) Then
            If btnSearchClicked Then
                Utility.ShowErrorLabel(LabelError, "Per effettuare la ricerca compilare una delle combinazioni di filtri come indicato.")
            End If
            result = False
        End If

        If String.IsNullOrEmpty(TxtRicovero.Text) Then
            '
            ' Se l'azienda erogante è valorizzata allora deve esserlo anche il numero nosologico
            '
            If Not String.IsNullOrEmpty(txtNumeroNosologico.Text) AndAlso String.IsNullOrEmpty(cmbAzienda.SelectedValue) Then
                Utility.ShowErrorLabel(LabelError, "Se il campo 'Numero Nosologico' è valorizzato allora è necessario selezionare l'Azienda Erogante.")
                result = False
            ElseIf String.IsNullOrEmpty(txtNumeroNosologico.Text) AndAlso Not String.IsNullOrEmpty(cmbAzienda.SelectedValue) Then
                Utility.ShowErrorLabel(LabelError, "Se l'Azienda Erogante è stata selezionata allora è necessario inserire un numero nosologico.")
                result = False
            End If
        End If

        '
        ' Controllo se l'id del Ricovero è un guid valido
        '
        If TxtRicovero.Text.Length > 0 AndAlso Not Utility.SQLTypes.IsValidGuid(TxtRicovero.Text) Then
            Utility.ShowErrorLabel(LabelError, "Il campo ID Ricovero non contiene un GUID valido.")
            result = False
        End If

        'CONTROLLO SE IL CAMPO IDPAZIENTE CONTIENE UN GUID VALIDO
        If Not String.IsNullOrEmpty(txtIdPaziente.Text) AndAlso Not Utility.SQLTypes.IsValidGuid(txtIdPaziente.Text) Then
            Utility.ShowErrorLabel(LabelError, "Il campo ID Paziente non contiene un GUID valido.")
            result = False
        End If


        If Not String.IsNullOrEmpty(txtIdPaziente.Text) Then
            If String.IsNullOrEmpty(txtDataModificaDal.Text) Then
                Utility.ShowErrorLabel(LabelError, "Se il campo 'ID Paziente' è valorizzato allora 'Data Modifica Dal' deve essere valorizzato.")
                result = False
            Else
                If Not Utility.SQLTypes.IsValidDateTime(txtDataModificaDal.Text) Then
                    Utility.ShowErrorLabel(LabelError, "Il campo 'Data Modifica Dal' non contiene una data valida.")
                    result = False
                End If
            End If

            If Not String.IsNullOrEmpty(txtDataModificaAl.Text) AndAlso Not Utility.SQLTypes.IsValidDateTime(txtDataModificaAl.Text) Then
                Utility.ShowErrorLabel(LabelError, "Il campo 'Data Modifica Al' non contiene una data valida.")
                result = False
            End If
        End If

        '
        ' Controllo se la data di nascita del paziente è una data valida
        '
        If txtDataNascita.Text.Length > 0 AndAlso Not Utility.SQLTypes.IsValidDateTime(txtDataNascita.Text) Then
            Utility.ShowErrorLabel(LabelError, "Il campo Data di Nascita non contiene una data valida.")
            result = False
        End If

        '
        'Controllo se la combinazione dei filtri è valida:
        '1) IdRicovero
        '2) Azienda + Nosologico
        '3) Nome,Cognome,Codice Fiscale e Data Nascita
        '
        If Not String.IsNullOrEmpty(txtDataNascita.Text) AndAlso Not String.IsNullOrEmpty(txtCognome.Text) AndAlso Not String.IsNullOrEmpty(txtNome.Text) AndAlso Not String.IsNullOrEmpty(txtCodiceFiscale.Text) Then
            Utility.ShowErrorLabel(LabelError, "Il campo Data di Nascita non contiene una data valida.")
            result = False
        End If

        'If String.IsNullOrEmpty(TxtRicovero.Text) AndAlso String.IsNullOrEmpty(txtNumeroNosologico.Text) AndAlso String.IsNullOrEmpty(cmbAzienda.SelectedValue) Then
        '    If Not String.IsNullOrEmpty(txtCodiceFiscale.Text) OrElse Not String.IsNullOrEmpty(txtNome.Text) OrElse Not String.IsNullOrEmpty(txtCognome.Text) OrElse Not String.IsNullOrEmpty(txtDataNascita.Text) Then
        '        Utility.ShowErrorLabel(LabelError, "Per effettuare la ricerca compilare una delle combinazioni di filtri come indicato.")
        '        result = False
        '    End If
        'End If

        Return result
    End Function

    Private Sub RicoveriListaObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles RicoveriListaObjectDataSource.Selecting
        Try
            If ValidateFilters() Then
                '
                'Gli altri parametri sono ControlParameter e quindi eseguono il bind diretto con le textbox del markup
                'Il guid lo passo da codice perchè controllo che sia realmente un guid corretto nella funzione "ValidateFilters"
                '
                If TxtRicovero.Text.Length > 0 Then
                    e.InputParameters("Id") = TxtRicovero.Text
                End If

                If txtDataNascita.Text.Length > 0 Then
                    e.InputParameters("DataNascita") = CType(txtDataNascita.Text, DateTime)
                End If

                If Not String.IsNullOrEmpty(txtIdPaziente.Text) Then
                    'DEVONO SEMPRE ESSERE VALORIZZATI.
                    e.InputParameters("dataModificaDAL") = CType(txtDataModificaDal.Text, DateTime)

                    'SOLO SE È VALORIZZATA LA TEXTBOX.
                    If Not String.IsNullOrEmpty(txtDataModificaAl.Text) Then
                        e.InputParameters("dataModificaAL") = CType(txtDataModificaAl.Text, DateTime)
                    End If
                End If

                If Not String.IsNullOrEmpty(txtIdPaziente.Text) Then
                    'PASSO L'ID DEL PAZIENTE.
                    e.InputParameters("idPaziente") = txtIdPaziente.Text
                End If
            Else
                e.Cancel = True
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub RicoveriListaObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles RicoveriListaObjectDataSource.Selected
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub RicoveriGridView_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles RicoveriGridView.RowCommand
        Try
            '
            ' Pulsante di rinotifica dei ricoveri.
            ' Vengono rinotificati tutti gli eventi di quel ricovero.
            '
            If e.CommandName = "Rinotifica" Then
                Using da = New RicoveriDataSetTableAdapters.QueriesTableAdapter
                    '
                    'Ottengo il numero della riga da cui ottenere NumeroNosologico e AziendaErogante.
                    '
                    Dim iRowNum As Integer = Integer.Parse(e.CommandArgument)

                    '
                    'Ottengo AziendaErogante e NumeroNosologico di quel ricovero.
                    '
                    Dim sAziendaErogante As String = RicoveriGridView.DataKeys(iRowNum).Values("AziendaErogante")
                    Dim sNumeroNosologico As String = RicoveriGridView.DataKeys(iRowNum).Values("NumeroNosologico")

                    '
                    'Richiamo la sp per la rinotifica degli eventi.
                    '
                    da.BeRicoveroNotificaEventi(sAziendaErogante, sNumeroNosologico)

                    '
                    '2020-07-07 Kyrylo: Traccia Operazioni
                    '
                    Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                    oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Rinotificati reventi ricovero", idPaziente:=Nothing, Nothing, sNumeroNosologico, "Numero nosologico")


                End Using
                Page.ClientScript.RegisterStartupScript(Me.GetType, "msg", "alert('Notifica accodata.');", True)

            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Protected Sub ClearFiltersButton_Click(sender As Object, e As EventArgs) Handles ClearFiltersButton.Click
        Try
            FilterHelper.Clear(filterPanel, msPAGEKEY)
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub RicoveriListaObjectDataSource_Deleting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles RicoveriListaObjectDataSource.Deleting
        Try
            ''
            ''Rimuovo gli imput parameter che vengono aggiunti di default dalla GridView:
            ''Se ho inserito delle DataKeyNames nella GridView, quando eseguo il metodo di cancellazione se non vengono rimossi causa un errore.
            ''
            e.InputParameters.Remove("AziendaErogante")
            e.InputParameters.Remove("NumeroNosologico")

            '
            '2020-07-07 Kyrylo: Traccia Operazioni
            '
            Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
            oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Cancellato ricovero", idPaziente:=Nothing, Nothing, e.InputParameters("Id").ToString(), "IdRicovero")

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub RicoveriListaObjectDataSource_Deleted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles RicoveriListaObjectDataSource.Deleted
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub RicoveriGridView_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles RicoveriGridView.RowDataBound
        Try
            If e.Row.RowType = DataControlRowType.DataRow Then
                Dim rw As DataRowView = e.Row.DataItem
                Dim oRow As DI.DataWarehouse.Admin.Data.BackEndDataSet.BeRicoveriListaRow = rw.Row
                If Not oRow.IsCodiceOscuramentoNull Then
                    e.Row.CssClass = "StileRicoveroOscurato"
                End If
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub cmbAzienda_PreRender(sender As Object, e As EventArgs) Handles cmbAzienda.PreRender
        Try
            Dim listItem As New ListItem With {.Text = "", .Value = ""}
            If cmbAzienda.Items.IndexOf(listItem) = -1 Then
                cmbAzienda.Items.Insert(0, listItem)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub
End Class