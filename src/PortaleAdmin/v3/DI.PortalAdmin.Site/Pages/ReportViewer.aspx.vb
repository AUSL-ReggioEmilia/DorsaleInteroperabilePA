Imports System
Imports System.Web.UI
Imports System.Configuration
Imports DI.PortalAdmin.Data

Namespace DI.PortalAdmin.Home

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

            Dim portalAdminDataAdapterManager = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

            portalAdminDataAdapterManager.TracciaAccessi(User.Identity.Name, PortalsNames.Home, "Report visualizzato: " & reportName)
        End Sub

    End Class

End Namespace