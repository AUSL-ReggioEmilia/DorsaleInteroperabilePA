Imports System
Imports System.Web.UI
Imports System.Configuration
Imports DI.Sac.Admin.Data
Imports DI.PortalAdmin.Data

Namespace DI.Sac.Admin

    Public Class ReportViewer
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

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

            Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

            portal.TracciaAccessi(User.Identity.Name, PortalsNames.Sac, "Report visualizzato: " & reportName)
        End Sub

    End Class

End Namespace