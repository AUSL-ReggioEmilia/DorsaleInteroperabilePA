Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Collections.Generic
Imports DI.PortalUser2.Data
Imports DI.OrderEntry.SacServices

Namespace DI.OrderEntry.User

	Public Class ListaPazienti
		Inherits Page

		Dim executeSelect As Boolean = False
		Private msPAGEKEY As String = Page.GetType().BaseType.FullName

		Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
			Redirector.SetTarget(Request.Url.AbsoluteUri, True)
			Try
				If Not Page.IsPostBack Then
					'Faccio il restore dei filtri precedentemente salvati dalla sessione corrente
					FilterHelper.Restore(pannelloFiltriRicerca, msPAGEKEY)
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		'Evento che scatta quando clicco sul pulsante cerca: prima effettuo la validazione dei requisiti e nel caso procedo con la query
		Private Sub btnCercaPazientiSac_Click(sender As Object, e As EventArgs) Handles btnCercaPazientiSac.Click
			Try
				If ValidaFiltri() Then
					executeSelect = True
					'Salvo in sessione tutti i filtri del pannelloFiltriRicerca
					FilterHelper.SaveInSession(pannelloFiltriRicerca, msPAGEKEY)
					gvPazientiSac.DataBind()

					'
					'2020-07-13 Kyrylo: Traccia Operazioni
					'
					Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalUser)
					oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Ricercato paziente", pannelloFiltriRicerca, Nothing)


				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		'Faccio il controllo su una variabile e in base ad essa decido se eseguire la query oppure no secondo una logica scelta
		Private Sub odsPazienti_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsPazienti.Selecting
			Try
				e.Cancel = Not executeSelect
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		'Faccio il redirect alla pagina ComposizioneOrdine.aspx passando per la funzione SalvaBozzaRichiesta()
		Private Sub gvPazientiSac_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvPazientiSac.RowCommand
			Try
				'Recupero i parametri necessari per comporre l'url su cui ridirezionare l'utente per la composizione dell'ordine
				Dim id As String = e.CommandArgument
				Dim resultSalvataggioBozza As String = Utility.SalvaBozzaRichiesta(id, String.Empty, String.Empty)
				Response.Redirect("ComposizioneOrdine.aspx?IdPaziente=" + id + "&IdRichiesta=" + resultSalvataggioBozza)
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		'Valido i filtri della pagina soggetti a regole
		Private Function ValidaFiltri() As Boolean
			Dim res As Boolean = False
			Try
				If String.IsNullOrEmpty(txtCognome.Text) AndAlso String.IsNullOrEmpty(txtCodiceFiscale.Text) Then
                    Throw New ApplicationException("Specificare almeno due lettere del cognome o il codice fiscale.")
                End If


				If Not String.IsNullOrEmpty(txtCodiceFiscale.Text) AndAlso txtCodiceFiscale.Text.Length <> 16 Then
					Throw New ApplicationException("Inserire un codice fiscale valido.")
				End If

                If Not String.IsNullOrEmpty(txtCognome.Text) AndAlso txtCognome.Text.Length < 2 Then
                    Throw New ApplicationException("Specificare almeno due lettere del cognome.")
                End If
                res = True
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
			Return res
		End Function

		'''<summary>
		''' Funzione per trappare gli errori e mostrare il div d'errore.
		''' </summary>
		''' <param name="ex"></param>
		Private Sub gestioneErrori(ex As Exception)

			'Testo di errore generico da visualizzare nel divError della pagina.
			Dim errorMessage As String = "Si è verificato un errore. Contattare l'amministratore del sito"

			'Se ex è una ApplicationException, allora contiene un messaggio di errore personalizzato che viene visualizzato poi
			'nel divError della pagina.
			If TypeOf ex Is ApplicationException Then
				errorMessage = ex.Message
			End If

			'Scrivo l'errore nell'event viewer.
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

			'Visualizzo il messaggio di errore nella pagina.
			divErrorMessage.Visible = True
			lblError.Text = errorMessage
		End Sub

		Private Sub odsPazienti_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsPazienti.Selected
			Try
				If Not e.ReturnValue Is Nothing Then
					Dim pazienti = CType(e.ReturnValue, List(Of PazientiCercaResponsePazientiCerca))
					If pazienti.Count >= 100 Then
						divSuperati100Risultati.Visible = "true"
					End If
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub
	End Class
End Namespace