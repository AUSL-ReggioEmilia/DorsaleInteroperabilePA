Imports DI.OrderEntry.User
Imports DI.PortalUser2.Data

Public Class StampaOrdine2
	Inherits System.Web.UI.Page

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Try
			SessionHandler.FromStampaOrdine = True
			Dim isAccessoDiretto As Boolean = False
			isAccessoDiretto = CType(RouteData.Values("AccessoDiretto"), Boolean)
			If isAccessoDiretto Then
				Me.MasterPageFile = "~/SiteAccessoDiretto.master"

			End If
			Dim sIdRicheista As String = Request.QueryString("IdRichiesta")
			alertErrore.Visible = False
			iframeStampaOrdine.Visible = True

			'
			'Se IdRichiesta è vuoto allora mostro un messaggio di errore
			'
			If String.IsNullOrEmpty(sIdRicheista) Then
				alertErrore.Visible = True
				iframeStampaOrdine.Visible = False
				lblErrore.Text = "Il parametro IdRichiesta non è corretto."
			Else
				'
				'Se IdRichiesta è valorizzato allora valorizzo l'url dell'iframe
				'
				iframeStampaOrdine.Attributes.Add("src", Utility.buildUrl($"~/Reports/ReportPdfViewer.aspx?idOrdine={sIdRicheista}", isAccessoDiretto))
			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			alertErrore.Visible = True
			lblErrore.Text = "Si è verificato un errore."
		End Try
	End Sub

	Private Sub btnIndietro_Click(sender As Object, e As EventArgs) Handles btnIndietro.Click
		Try
			'
			'Eseguo un redirect alla home
			'
			Response.Redirect("~/Pages/ListaOrdini.aspx", False)
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			alertErrore.Visible = True
			lblErrore.Text = "Si è verificato un errore."
		End Try
	End Sub
End Class