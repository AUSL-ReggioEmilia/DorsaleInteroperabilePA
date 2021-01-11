Imports System.Web.UI
Imports DI.PortalUser2.Data
Imports DI.OrderEntry.User.Data
Imports System.Collections.Generic
Imports System.Linq

Namespace DI.OrderEntry.User

	Public Class PazientePerNosologico
		Inherits Page

		Protected ReadOnly Property Azienda As String
			Get
				''2015-05-07:  SU INDICAZIONE DI CORRADO VIENE UTILIZZATO IL PRIMO CODICE AZIENDA
				'  CHE TROVO NELLE UNITA' OPERATIVE LEGATE AL RUOLO CORRENTE
				'  SI DA PER SCONTATO CHE IL RUOLO DEBBA ESSERE MONO AZIENDA
				Dim customDataSource As New CustomDataSource.UnitaOperative
				Dim unitaOperative As List(Of UnitaOperativa) = customDataSource.GetData()
				If unitaOperative.Count = 0 Then
					'
					'l'utente non ha i permessi sulle UO
					'
					'Throw New Exception("DataAdapterManager.GetLookupUOPerRuolo non ha restituito righe.")
					Throw New ApplicationException("Per il ruolo corrente non sono state configurate le Unità Operative. Contattare l'amministratore.")

				End If
				Return unitaOperative(0).CodiceAzienda
			End Get
		End Property

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
			Try
				Redirector.SetTarget(Request.Url.AbsoluteUri, True)

				If Not Page.IsPostBack Then
					'
					' [TASK = 3232] INSERIMENTO DI UN FILTRO AZIENDA CON DEFAULT L'AZIENDA COLLEGATA ALL'ACCOUNT
					' IN BASE AL DOMINIO CON CUI SI ACCEDE SETTO IL VALORE DELLA COMBO
					'
					Dim azienda As String = Utility.GetAzienda(User.Identity.Name)
					If Not String.IsNullOrEmpty(azienda) Then
						ddlAzienda.SelectedValue = azienda
					End If
				End If

				txtNosologico.Focus()

			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		Private Sub btnCerca_Click(sender As Object, e As EventArgs) Handles btnCerca.Click
			Try
				If ValidaFiltri() Then
					'Eseguo la trascodifica dei primi due caratteri
					Dim primiCaratteri As String = txtNosologico.Text.Substring(0, 2)
					Dim ultimiCaratteri As String = txtNosologico.Text.Substring(2, txtNosologico.Text.Length - 2)

					'Ottengo il nosologico
					Dim nosologico As String = txtNosologico.Text
					Select Case primiCaratteri
						Case "10"
							nosologico = "I" + ultimiCaratteri
						Case "12"
							nosologico = "I" + ultimiCaratteri

						Case "11"
							nosologico = "D" + ultimiCaratteri
						Case "13"
							nosologico = "P" + ultimiCaratteri
					End Select

					'Verifico che esista il Nosologico + azienda.
					Dim sIdPazienteUnitOp As String = Utility.GetIdPazienteByNosologico(nosologico, ddlAzienda.SelectedValue)

					'Vado avanti solo se è valorizzato l'id del paziente.
					If Not String.IsNullOrEmpty(sIdPazienteUnitOp) Then
						'formato  [idPaziente]§[codice unità operativa]
						'Se arrivo qui allora result = idPaziente + unità operativa
						Dim idPazienteEUo = sIdPazienteUnitOp
						Dim arrayIdPazEUnitaOp As String() = idPazienteEUo.Split("§")

						Dim idPaziente As String = arrayIdPazEUnitaOp(0)
						Dim aziendaUnitaOperativa As String = String.Format("{0}-{1}", ddlAzienda.SelectedValue, arrayIdPazEUnitaOp(1))

						Dim idRichiesta As String = Utility.SalvaBozzaRichiesta(idPaziente, nosologico, aziendaUnitaOperativa)

						If String.IsNullOrEmpty(idRichiesta) Then
							Throw New ApplicationException("Si è verificato un errore.")
						Else
							'Creo i parametri da passare nel query string.
							Dim paramNosologico As String = String.Empty
							If Not String.IsNullOrEmpty(nosologico) Then
								paramNosologico = String.Format("&Nosologico={0}", nosologico)
							End If

							Dim paramAziendaUO As String = String.Empty
							If Not String.IsNullOrEmpty(aziendaUnitaOperativa) Then
								paramAziendaUO = String.Format("&AziendaUo={0}", aziendaUnitaOperativa)
							End If

							'
							'2020-07-13 Kyrylo: Traccia Operazioni
							'
							Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalUser)
							oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Visualizzato paziente ricoverato per nosologico", New Guid(idPaziente), Nothing, idRichiesta, "IdRichiesta")

							Response.Redirect(String.Format("~/Pages/ComposizioneOrdine.aspx?IdPaziente={0}&IdRichiesta={1}{2}", idPaziente, idRichiesta, paramNosologico & paramAziendaUO))
						End If
					End If
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try
		End Sub

		''' <summary>
		''' Funzione di validazione dei filtri.
		''' </summary>
		''' <returns></returns>
		Private Function ValidaFiltri() As Boolean
			Dim res As Boolean = False
			Try
				If String.IsNullOrEmpty(txtNosologico.Text) OrElse String.IsNullOrEmpty(ddlAzienda.SelectedValue) Then
					Throw New ApplicationException("Il numero nosologico e l'azienda devono essere valorizzati.")

				Else
					res = True
				End If

			Catch ex As ApplicationException
				divErrorMessage.Visible = True
				lblError.Text = ex.Message

				res = False
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

	End Class

End Namespace