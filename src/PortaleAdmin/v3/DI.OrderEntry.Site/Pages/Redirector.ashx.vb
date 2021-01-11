Imports System.Web
Imports System.Web.Services

Public Class Redirector
	Implements System.Web.IHttpHandler

	'
	' HANDLER USATO PER GESTIRE I REDIRECT VERSO SITI ESTERNI ALL'ORDER ENTRY
	'
	'
	Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest

		context.Response.ContentType = "text/plain"

		Select Case context.Request.QueryString("Target")

			Case "UnitaOperative"
				HttpContext.Current.Response.Redirect(My.Settings.UnitaOperativeSacUrl)
			Case "Ruoli"
				HttpContext.Current.Response.Redirect(My.Settings.RuoliSacUrl)
			Case Nothing
				HttpContext.Current.Response.Redirect("~/MissingResource.htm")
			Case Else
				HttpContext.Current.Response.Redirect("~/MissingResource.htm")
		End Select

	End Sub

	ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
		Get
			Return False
		End Get
	End Property

End Class