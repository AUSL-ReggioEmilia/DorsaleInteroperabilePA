Imports System.Web.UI.HtmlControls
Imports DI.OrderEntry.User
Imports DI.PortalUser2.Data

Public Class AccessoDirettoMessage
	Inherits System.Web.UI.Page

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Try
			Dim master As SiteAccessoDiretto = CType(Me.Master, SiteAccessoDiretto)
			master.NascondiPannelloUtente()


			Dim mode As String = Request.QueryString("Mode")
			Select Case mode.ToLowerInvariant
				Case "error"
					Me.divCriticalErrorMessage.Visible = True
				Case "saved"
					divOrderSuccesfullySaved.Visible = True
				Case "deleted"
					divOrderSuccesfullyDeleted.Visible = True
				Case Else
					Throw New ApplicationException("Parametri di QueryString non validi")
			End Select

		Catch ex As ApplicationException
			pErrorMessage.InnerText = ex.Message
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
			pErrorMessage.InnerText = ex.Message
		End If

		'Scrivo l'errore nell'event viewer.
		ExceptionsManager.TraceException(ex)
		Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
		portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

		'Visualizzo il messaggio di errore nella pagina.
		pErrorMessage.InnerText = errorMessage
	End Sub

End Class