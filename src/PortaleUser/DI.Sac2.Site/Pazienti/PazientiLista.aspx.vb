
Imports CustomDataSource
Imports DI.Common
Imports DI.PortalUser2.Data

Namespace DI.Sac.User

    Partial Public Class PazientiLista
        Inherits System.Web.UI.Page

        Private Shared ReadOnly _ClassName As String = System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name

        Private formMaster As HtmlForm

        Private enableSelect As Boolean = False


        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try
                If Not Page.IsPostBack Then
                    Dim cookie As HttpCookie = Nothing
                    FilterHelper.Restore(pannelloFiltri, cookie)

                    'Se almeno una textbox è valorizzata e il campo IdSac invece non lo è allora eseguo la query
                    If (Not String.IsNullOrEmpty(txtCognome.Text) OrElse Not String.IsNullOrEmpty(txtNome.Text) OrElse Not String.IsNullOrEmpty(txtAnnoNascita.Text) _
                    OrElse Not String.IsNullOrEmpty(txtCodiceFiscale.Text)) And (String.IsNullOrEmpty(txtIdSac.Text)) Then
                        enableSelect = True
                    End If
                End If

                ' Default Focus/Button
                If Master.TryFindControl(Of HtmlForm)("form1", formMaster) Then

                    formMaster.DefaultFocus = txtCognome.ClientID
                    formMaster.DefaultButton = btnRicerca.UniqueID
                End If
            Catch ex As Exception

                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub

        Protected Sub btnRicerca_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnRicerca.Click
            Try
                enableSelect = True
                'verifico che i filtri siano validi.
                If RicercaIsValid() Then
                    'salvo i filtri in sessione.
                    FilterHelper.SaveInSession(pannelloFiltri)

                    If Not String.IsNullOrEmpty(txtIdSac.Text) Then
                        'instanzio un nuovo oggetto di tipo pazientiottieniperid e ne cancello la cache.
                        Dim pazientiOttieniPerId As New PazientiOttieniPerId()
                        pazientiOttieniPerId.ClearCache()

                        'ottengo il paziente in base al suo Id.
                        'se il paziente è valorizzato faccio un redirect alla pagina di dettaglio
                        Dim paziente As WcfSacPazienti.PazienteType = pazientiOttieniPerId.GetData(Nothing, Guid.Parse(txtIdSac.Text))
                        If paziente IsNot Nothing Then
                            Response.Redirect("~/Pazienti/PazienteDettaglio.aspx?id=" & paziente.IdSac.ToString)
                        End If
                    Else
                        'eseguo il bind dei dati.
                        gvPazienti.DataBind()
                    End If

                    '
                    '2020-07-13 Kyrylo: Traccia Operazioni
                    '
                    Dim oTracciaOp As New TracciaOperazioniManager(Utility.ConnectionStringPortalUser)
                    oTracciaOp.TracciaOperazione(PortalsNames.Sac, Page.AppRelativeVirtualPath, "Ricerca paziente", pannelloFiltri, Nothing)

                End If
            Catch ex As Exception

                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub


        ''' <summary>
        ''' Funzione che si occupa di verificare se la ricerca è valida
        ''' </summary>
        ''' <returns></returns>
        Private Function RicercaIsValid() As Boolean
            Dim result As Boolean = False

            Try
                'Almeno uno tra Cognome Medico, Cognome e IdSac deve essere compilato.
                If String.IsNullOrEmpty(txtCognomeMedico.Text) AndAlso String.IsNullOrEmpty(txtCognome.Text) AndAlso String.IsNullOrEmpty(txtIdSac.Text) Then
                    Throw New ApplicationException("Specificare almeno uno tra Cognome, Cognome Medico e IdSac.")
                Else
                    'Verifico che se il campo IdSac è valorizzato, allora è anche compilato con un GUID valido
                    If Not String.IsNullOrEmpty(txtIdSac.Text) Then
                        Dim guid As New Guid
                        If Not Guid.TryParse(txtIdSac.Text, guid) Then
                            Throw New ApplicationException("Il campo IdSac deve essere valorizzato con un Guid valido.")
                        End If
                    End If

                    'Se Cognome Medico è valorizzato ma è meno di due lettere mostro un messaggio d'errore.
                    'Se Cognome Medico NON è valorizzato e Nome Medico è valorizzato allora mostro un messaggio d'errore.
                    If Not String.IsNullOrEmpty(txtCognomeMedico.Text) Then
                        If txtCognomeMedico.Text.Length < 2 Then
                            Throw New ApplicationException("Specificare almeno due lettere di Cognome Medico.")
                        End If
                    Else
                        If Not String.IsNullOrEmpty(txtNomeMedico.Text) Then
                            Throw New ApplicationException("Se Nome Medico è valorizzato allora anche Cognome Medico deve esserlo.")
                        End If
                    End If

                    'Almeno due lettere del cognome devono essere valorizzate.
                    If Not String.IsNullOrEmpty(txtCognome.Text) AndAlso txtCognome.Text.Length < 2 Then
                        Throw New ApplicationException("Specificare almeno due lettere del Cognome del paziente.")
                    End If
                End If

                result = True
            Catch ex As ApplicationException
                result = False
                'Si è verificato un errore applicativo.
                Master.ShowErrorLabel(ex.Message)
            Catch ex As Exception
                result = False
                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
            Return result
        End Function


        Private Sub PazientiGridView_PreRender(sender As Object, e As EventArgs) Handles gvPazienti.PreRender
            Try
                '
                'Render per Bootstrap
                'Crea la Table con Theader e Tbody se l'header non è nothing.
                '
                If Not gvPazienti.HeaderRow Is Nothing Then
                    gvPazienti.UseAccessibleHeader = True
                    gvPazienti.HeaderRow.TableSection = TableRowSection.TableHeader
                End If
            Catch ex As Exception

                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub

        Private Sub odsLista_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
            Try
                'Se non è stato premuto il pulsante cerca cancello la query.
                If Not enableSelect Then
                    e.Cancel = True
                End If

                e.InputParameters("Token") = Nothing 'IMPORTANTE: il Token non è obbligatorio.In questo caso non è necessario passarlo.
                e.InputParameters("Cognome") = txtCognome.Text
                e.InputParameters("Nome") = txtNome.Text

                'ottengo l'anno di nascita.
                Dim annoNascita As Integer? = Nothing
                If Not String.IsNullOrEmpty(txtAnnoNascita.Text) Then
                    'casto a Integer il contenuto della textbox txtAnnoNascita.
                    annoNascita = CType(txtAnnoNascita.Text, Integer)
                End If
                e.InputParameters("AnnoNascita") = annoNascita
                e.InputParameters("CodiceFiscale") = txtCodiceFiscale.Text

                e.InputParameters("MedicoDiBaseCognome") = If(String.IsNullOrEmpty(txtCognomeMedico.Text), Nothing, txtCognomeMedico.Text)
                e.InputParameters("MedicoDiBaseNome") = If(String.IsNullOrEmpty(txtNomeMedico.Text), Nothing, txtNomeMedico.Text)
                e.InputParameters("ComuneResidenzaNome") = If(String.IsNullOrEmpty(txtComuneResidenza.Text), Nothing, txtComuneResidenza.Text)
            Catch ex As Exception
                'Si è verificato un errore.
                Master.ShowErrorLabel(GestioneErrori.TrapError(ex))
            End Try
        End Sub

        Private Sub odsLista_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
            Try
                'testo se si è verificato un errore.
                If e.Exception IsNot Nothing Then
                    e.ExceptionHandled = True
                    'ottengo il messaggio di errore.
                    Throw e.Exception
                End If

                'Non si è verificato nessun errore.
                Dim result As WcfSacPazienti.PazientiListaType = CType(e.ReturnValue, WcfSacPazienti.PazientiListaType)

                gvPazienti.Visible = True
                divEmptyRow.Visible = False
                If result Is Nothing OrElse result.Count = 0 Then
                    divEmptyRow.Visible = True
                    gvPazienti.Visible = False
                End If
            Catch ex As Exception
                'Si è verificato un errore.
                '
                'ATTENZIONE:
                'Chiamo il metodo CustomDataSourceException.TrapError(ex) al posto di GestioneErrori.TrapError perchè questa objectdatasource chiama una CustomDataSource
                ' che ottiene i dati da un WCF.
                'iN questo modo trappo anche gli errori generati dal WCF.
                Master.ShowErrorLabel(CustomDataSourceException.TrapError(ex))
            End Try
        End Sub

        Private Sub gvPazienti_Sorting(sender As Object, e As GridViewSortEventArgs) Handles gvPazienti.Sorting
            enableSelect = True
        End Sub

        Private Sub gvPazienti_SelectedIndexChanging(sender As Object, e As GridViewSelectEventArgs) Handles gvPazienti.SelectedIndexChanging
            enableSelect = True
        End Sub
    End Class

End Namespace