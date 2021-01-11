Imports System.Web
Imports System
Imports DI.OrderEntry.User
Imports DI.PortalUser2.Data
Imports System.Configuration

Public Class _Default
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            HttpContext.Current.Response.Redirect("~/Pages/Home.aspx")
        Catch ex As Threading.ThreadAbortException
            'in caso di redirect alla pagina di Composizione Ordine
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			'Dim portal = New PortalDataAdapterManager(Global_asax.sPortalUserConnectionString)

            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

            Throw
        End Try

    End Sub

End Class