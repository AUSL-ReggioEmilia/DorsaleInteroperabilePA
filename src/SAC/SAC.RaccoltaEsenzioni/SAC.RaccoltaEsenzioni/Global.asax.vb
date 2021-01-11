Imports System.Web.Optimization
Imports Microsoft.ApplicationInsights.Extensibility
Imports SAC.RaccoltaEsenzioni.CustomInitializer.Telemetry

Public Class Global_asax
    Inherits HttpApplication

    Sub Application_Start(sender As Object, e As EventArgs)
        'necessario per far funzionare la validazione cliendside
        'ValidationSettings.UnobtrusiveValidationMode = UnobtrusiveValidationMode.None

        ' Fires when the application is started
        'RouteConfig.RegisterRoutes(RouteTable.Routes)
        BundleConfig.RegisterBundles(BundleTable.Bundles)


        TelemetryConfiguration.Active.TelemetryInitializers.Add(New MyTelemetryInitializer())
    End Sub
End Class