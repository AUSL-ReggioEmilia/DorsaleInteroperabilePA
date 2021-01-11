Imports System
Imports System.Web.UI
Imports System.Configuration
Imports DI.OrderEntry.User.Data
Imports DI.PortalUser2.Data

Namespace DI.OrderEntry.User

	Public Class ReportViewer
		Inherits Page

		Dim isAccessoDiretto As Boolean = False
		Protected Sub ReportViewer_PreInit(sender As Object, e As EventArgs) Handles Me.PreInit
			Try
				If RouteData.Values("AccessoDiretto") IsNot Nothing Then
					isAccessoDiretto = CType(RouteData.Values("AccessoDiretto"), Boolean)
					If isAccessoDiretto Then
						Me.MasterPageFile = "~/SiteAccessoDiretto.master"
					End If
				End If
			Catch ex As Exception
				gestioneErrori(ex)
			End Try

		End Sub

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
			Try
				Dim type = Request("repository") 'di, dwh, url
				Dim reportName = Request("reportName")

				If reportName Is Nothing Then
					Return
				End If

				Dim url As String

				Select Case type

					Case "di"
						url = String.Format(My.Settings.ReportingUrl, reportName)

					Case Else

						url = reportName
				End Select

				Dim urlContent As String = Me.ResolveUrl(url)

				Me.IframeMain.Attributes.Add("src", urlContent)

				DataAdapterManager.PortalAdminDataAdapterManager.TracciaAccessi(User.Identity.Name, PortalsNames.OrderEntry, "Report visualizzato: " & reportName)
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