Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Collections.Generic
Imports DI.PortalUser2.Data

Namespace DI.OrderEntry.User
	Public Class ListaPazientiRicoverati
		Inherits Page

		Dim executeSelectRicoverati As Boolean = False
		Private msPAGEKEY As String = Page.GetType().BaseType.FullName

		Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
			Redirector.SetTarget(Request.Url.AbsoluteUri, True)
			Try
				If Not Page.IsPostBack Then
					executeSelectRicoverati = True
					'Carico la prima ddl delle unità operative.
					ddlUO.DataBind()
					If ddlUO.Items.Count = 0 Then
						Throw New ApplicationException("Nessuna unità operativa configurata per il ruolo corrente.")
					Else
						FilterHelper.Restore(pannelloFiltriRicoverati, msPAGEKEY)
						'Carico la seconda ddl dei Tipi di ricovero (questa combo viene popolata in base al selected value delle unità operative)
						ddlTipoRicovero.DataBind()
						FilterHelper.Restore(pannelloFiltriRicoverati, msPAGEKEY)
					End If

					'
					'2020-07-13 Kyrylo: Traccia Operazioni
					'
					Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalUser)
					oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Visualizzata lista pazienti ricoverati", idPaziente:=Nothing, Nothing)

				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub


		'Valido i filtri della pagina soggetti a regole
		Private Function ValidaFiltriRicoverati() As Boolean
			Dim res As Boolean = True
			Try
				If (((String.Equals(ddlTipoRicovero.SelectedValue, "S")) OrElse (String.Equals(ddlTipoRicovero.SelectedValue, "D")) OrElse (CType((ddlStatoEpisodio.SelectedValue), Integer) = 3) OrElse (CType((ddlStatoEpisodio.SelectedValue), Integer) = 0)) AndAlso (txtCognomeRicoverati.Text.Length < 2)) Then
					Throw New ApplicationException("Specificare almeno 2 lettere del cognome")
					divErrorMessage.Visible = True
					lblError.Text = "Specificare almeno 2 lettere del cognome"
				ElseIf (txtNomeRicoverati.Text.Length > 0) Then
					If (txtCognomeRicoverati.Text.Length = 0) Then
						Throw New ApplicationException("Se il filtro 'Nome' è valorizzato allora specificare anche il cognome.")
						divErrorMessage.Visible = True
						lblError.Text = "Se il filtro 'Nome' è valorizzato allora specificare anche il cognome."
					End If
				End If
			Catch ex As Exception
				res = False
				gestioneErrori(ex)
			End Try
			Return res
		End Function

		Private Sub ddlUO_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlUO.SelectedIndexChanged
			Try
				ddlTipoRicovero.ClearSelection()
				ddlTipoRicovero.DataBind()
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub odsTipoRicovero_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsTipoRicovero.Selecting
			Try
				e.InputParameters("AziendaUnitaOperativa") = ddlUO.SelectedItem.Value
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub btnCercaRicoverati_Click(sender As Object, e As EventArgs) Handles btnCercaRicoverati.Click
			Try
				If ValidaFiltriRicoverati() Then
					executeSelectRicoverati = True
					gvPazientiRicoverati.DataBind()
					FilterHelper.SaveInSession(pannelloFiltriRicoverati, msPAGEKEY)

					'
					'2020-07-13 Kyrylo: Traccia Operazioni
					'
					Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalUser)
					oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Ricerca pazienti ricoverati", pannelloFiltriRicoverati, Nothing)

				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub odsPazientiRicoverati_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsPazientiRicoverati.Selecting
			Try
				e.Cancel = Not executeSelectRicoverati
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub odsPazientiRicoverati_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsPazientiRicoverati.Selected
			Try
				If Not e.ReturnValue Is Nothing Then
					Dim pazienti = CType(e.ReturnValue, List(Of WcfDwhClinico.PazienteListaType))
					If pazienti.Count >= 100 Then
						divSuperati100Risultati.Visible = "true"
					End If
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Protected Function getConsensoImg(consenso As String) As String
			Dim ret As String = String.Empty
			Try
				If Not String.IsNullOrEmpty(consenso) Then
					Dim bConsenso As Boolean = CType(consenso, Boolean)
					If bConsenso Then
						ret = "../Images/ok.png"
					End If
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
			Return ret
		End Function

		Private Sub gvPazientiRicoverati_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvPazientiRicoverati.RowCommand
			Try
				'Ottengo la row
				Dim gvr As GridViewRow = CType(CType(e.CommandSource, Button).NamingContainer, GridViewRow)

				'Ottengo l'index della row
				Dim RowIndex As Integer = gvr.RowIndex

				'Ottengo le informazioni dalla DataKeys
				Dim idPaziente As String = gvPazientiRicoverati.DataKeys(RowIndex)("Id")
				Dim nosologico As String = gvPazientiRicoverati.DataKeys(RowIndex)("EpisodioNumeroNosologico")
				Dim aziendaErogante As String = gvPazientiRicoverati.DataKeys(RowIndex)("EpisodioAziendaErogante")
				Dim episodioStrutturaUltimoEventoCodice As String = gvPazientiRicoverati.DataKeys(RowIndex)("EpisodioStrutturaUltimoEventoCodice")
				Dim episodioStrutturaConclusioneCodice As String = gvPazientiRicoverati.DataKeys(RowIndex)("EpisodioStrutturaConclusioneCodice")

				'Compondo il parametro "aziendaUo" da passare alla pagina ComposizioneOrdine
				Dim aziendaUo As String = String.Format("{0}-{1}", aziendaErogante, If(String.IsNullOrEmpty(episodioStrutturaUltimoEventoCodice), episodioStrutturaConclusioneCodice, episodioStrutturaUltimoEventoCodice))

				'Salvo l'ordine in bozza e ottengo idRichiesta
				Dim resultSalvataggioBozza As String = Utility.SalvaBozzaRichiesta(idPaziente, nosologico, aziendaUo)

				'Creo l'url per la pagina di composizione dell'ordine.
				Dim url As String = String.Format("~/Pages/ComposizioneOrdine.aspx?IdPaziente={0}&IdRichiesta={1}&Nosologico={2}&AziendaUo{3}", idPaziente, resultSalvataggioBozza, nosologico, aziendaUo)

				'eseguo il redirect.
				Response.Redirect(url)
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

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
	End Class
End Namespace