Imports System
Imports System.Security.Principal
Imports System.Web.SessionState
Imports System.Web
Imports System.Diagnostics
Imports DI.PortalAdmin.Data
Imports System.Configuration
Imports System.Collections.Generic
Imports System.Web.UI
Imports Microsoft.ApplicationInsights
Imports CustomInitializer.Telemetry
Imports Microsoft.ApplicationInsights.Extensibility
'Imports System.DirectoryServices.AccountManagement
'Imports DI.Security

Namespace DI.PortalAdmin

    Public Class Global_asax
        Inherits HttpApplication

        Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
            ' Code that runs on application startup
            Dim sJqueryVer As String = "3.5.1"

            ScriptManager.ScriptResourceMapping.AddDefinition("jquery", New ScriptResourceDefinition() With {
           .Path = String.Format("~/Scripts/jquery-{0}.min.js", sJqueryVer),
           .DebugPath = String.Format("~/Scripts/jquery-{0}.js", sJqueryVer),
           .CdnSupportsSecureConnection = False,
           .LoadSuccessExpression = "window.jQuery"})

            ScriptManager.ScriptResourceMapping.AddDefinition("bootstrap", New ScriptResourceDefinition() With {
                .Path = "~/Scripts/bootstrap.min.js",
                .DebugPath = "~/Scripts/bootstrap.js"})

            ScriptManager.ScriptResourceMapping.AddDefinition("respond", New ScriptResourceDefinition() With {
                .Path = "~/Scripts/respond.min.js",
                .DebugPath = "~/Scripts/respond.js"})

            Dim sModernVer As String = "2.8.3"

            ScriptManager.ScriptResourceMapping.AddDefinition("modernizr", New ScriptResourceDefinition() With {
                .Path = String.Format("~/Scripts/modernizr-{0}.js", sModernVer),
                .DebugPath = String.Format("~/Scripts/modernizr-{0}.js", sModernVer)})

            ScriptManager.ScriptResourceMapping.AddDefinition("moment", New ScriptResourceDefinition() With {
                .Path = "~/Scripts/moment.min.js",
                .DebugPath = "~/Scripts/moment.js"})

            ScriptManager.ScriptResourceMapping.AddDefinition("momentLocales", New ScriptResourceDefinition() With {
              .Path = "~/Scripts/moment-with-locales.min.js",
              .DebugPath = "~/Scripts/moment-with-locales.js"})

            ScriptManager.ScriptResourceMapping.AddDefinition("datetimepicker", New ScriptResourceDefinition() With {
              .Path = "~/Scripts/bootstrap-datetimepicker.min.js",
              .DebugPath = "~/Scripts/bootstrap-datetimepicker.js"})

            '
            ' Inizializzazione per AppInsight
            '
            TelemetryConfiguration.Active.TelemetryInitializers.Add(New MyTelemetryInitializer())

        End Sub


        Sub Application_BeginRequest(ByVal sender As Object, ByVal e As EventArgs)

        End Sub

        Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)

            Dim lastException As Exception = Server.GetLastError()

            If lastException IsNot Nothing Then

                ExceptionsManager.TraceException(lastException)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

                portal.TracciaErrori(lastException, User.Identity.Name, PortalsNames.Home)
            End If

            '
            'Gestione degli errori su application insights.
            '
            '
            'Raccolgo gli errori su azure.
            '
            If HttpContext.Current.IsCustomErrorEnabled AndAlso Server.GetLastError() IsNot Nothing Then
                Dim ai = New TelemetryClient()
                ' or re-use an existing instance
                ai.TrackException(Server.GetLastError())
            End If
        End Sub


        Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
            ' Fires when the application ends
        End Sub

    End Class

End Namespace