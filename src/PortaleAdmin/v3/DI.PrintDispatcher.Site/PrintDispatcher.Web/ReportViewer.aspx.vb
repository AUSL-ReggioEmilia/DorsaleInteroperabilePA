Partial Public Class ReportViewer
    Inherits System.Web.UI.Page

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

        Dim oPortalDataAdapterManager As New DI.PortalAdmin.Data.PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
        oPortalDataAdapterManager.TracciaAccessi(User.Identity.Name,
                        DI.PortalAdmin.Data.PortalsNames.PrintDispatcher,
                        "Report visualizzato: " & reportName)

    End Sub

End Class