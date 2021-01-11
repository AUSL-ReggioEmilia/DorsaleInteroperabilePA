Imports Microsoft.ApplicationInsights.DependencyCollector
Imports Microsoft.ApplicationInsights.Extensibility
Imports Microsoft.ApplicationInsights.Extensibility.PerfCounterCollector
Imports OE.Core

Public Class TelemetryHelper

    Public Shared Sub Initialize()
        '
        ' Initialize Application Insight aggiungendo un custom Initializer se non c'è già
        '
        Dim Initializers = TelemetryConfiguration.Active.TelemetryInitializers
        Dim bDone As Boolean = Initializers.Where(Function(i) i.GetType() = GetType(TelemetryInitializer)).Any()
        If Not bDone Then
            '
            ' Aggiungo un Processor (rimuove telemetry non necessari)
            '
            Dim builder = TelemetryConfiguration.Active.DefaultTelemetrySink.TelemetryProcessorChainBuilder
            builder.Use(Function(nextProc) New TelemetryProcessor(nextProc))
            builder.Build()
            '
            ' Add TelemetryInitializer
            '
            TelemetryConfiguration.Active.TelemetryInitializers.Add(New TelemetryInitializer())
            '
            ' Initialize Dependency Tracking. In WCF non è automatico
            ' Il settaggio di EnableSqlCommandTextInstrumentation non sembra funzionare
            '   E' stato aggiunto al ApplicationInsights.config
            '   Sembra che DependencyTrackingTelemetryModule sia già inizializzato
            '
            Dim depModule As DependencyTrackingTelemetryModule = New DependencyTrackingTelemetryModule()
            depModule.EnableSqlCommandTextInstrumentation = True
            depModule.Initialize(TelemetryConfiguration.Active)
            '
            ' Initialize Performance Collector Module. In WCF non è automatico
            '
            Dim perfModule As PerformanceCollectorModule = New PerformanceCollectorModule()
#If DEBUG Then
            perfModule.EnableIISExpressPerformanceCounters = True
#End If
            perfModule.Initialize(TelemetryConfiguration.Active)
            '
            ' Log Init
            '
            DiagnosticsHelper.WriteDiagnostics($"TelemetryInitializer completata.")
        End If

    End Sub

End Class
