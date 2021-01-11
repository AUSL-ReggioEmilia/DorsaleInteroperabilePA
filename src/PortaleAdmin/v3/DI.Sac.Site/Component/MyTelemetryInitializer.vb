Imports Microsoft.ApplicationInsights.Channel
Imports Microsoft.ApplicationInsights.Extensibility

Namespace CustomInitializer.Telemetry
	Public Class MyTelemetryInitializer
		Implements ITelemetryInitializer

        Public Shared InstrumentationKey As String = My.Settings.InstrumentationKey
        Public Const RoleName = "SAC-Admin"

        Private Sub ITelemetryInitializer_Initialize(telemetry As ITelemetry) Implements ITelemetryInitializer.Initialize
            If (String.IsNullOrEmpty(telemetry.Context.Cloud.RoleName)) Then
                telemetry.Context.Cloud.RoleName = RoleName
                telemetry.Context.InstrumentationKey = InstrumentationKey
            End If
        End Sub
	End Class
End Namespace
