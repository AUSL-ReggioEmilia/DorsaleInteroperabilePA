Imports Microsoft.ApplicationInsights.Extensibility
Imports Microsoft.ApplicationInsights.Channel
Imports Microsoft.ApplicationInsights.DataContracts

Namespace CustomProcessor.Telemetry
    Public Class MyTelemetryProcessor
        Implements ITelemetryProcessor

        Private [Next] As ITelemetryProcessor

        Public Sub New(ByVal [next] As ITelemetryProcessor)
            Me.[Next] = [next]
        End Sub

        Public Sub Process(ByVal item As ITelemetry) Implements ITelemetryProcessor.Process
            Dim requestTelemetry As RequestTelemetry = TryCast(item, RequestTelemetry)

            If requestTelemetry IsNot Nothing AndAlso requestTelemetry.Url.AbsolutePath.EndsWith("/GetIconaTipoReferto.ashx", StringComparison.OrdinalIgnoreCase) Then
                Return
            Else
                [Next].Process(item)
            End If

        End Sub
    End Class
End Namespace
