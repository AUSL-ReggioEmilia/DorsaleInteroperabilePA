Imports Microsoft.ApplicationInsights.Channel
Imports Microsoft.ApplicationInsights.DataContracts
Imports Microsoft.ApplicationInsights.Extensibility
Imports OE.Core

Public Class TelemetryProcessor
    Implements ITelemetryProcessor
    Private Property _Next As ITelemetryProcessor

    Public Sub New([next] As ITelemetryProcessor)
        _Next = [next]
    End Sub

    Public Sub Process(ByVal item As ITelemetry) Implements ITelemetryProcessor.Process
        '
        ' Non traccio gli errori dell'SDK
        '
        'If Not String.IsNullOrEmpty(item.Context.Operation.SyntheticSource) Then
        '    Return
        'End If

        '
        ' Tipo di telemetry da valutare
        '
        If TypeOf item Is DependencyTelemetry Then
            '
            ' Tipo DependencyTelemetry
            '
            Dim dependency = TryCast(item, DependencyTelemetry)
            If dependency IsNot Nothing Then
                '
                ' Controllo durata se minore non traccio
                '
                If Helper.AppInsightsDependecyMinDuration > 0 Then
                    If dependency.Success = True AndAlso dependency.Duration.TotalMilliseconds < Helper.AppInsightsDependecyMinDuration Then
                        Return
                    End If
                End If
                '
                ' Specifici per tipo
                '
                If String.Equals(dependency.Type, "SQL", StringComparison.OrdinalIgnoreCase) Then
                    '
                    ' Controllo command da non tracciare
                    '
                    If dependency.Success = True AndAlso String.Equals(dependency.Data, "dbo.NonTracciare", StringComparison.OrdinalIgnoreCase) Then
                        Return
                    End If

                ElseIf String.Equals(dependency.Type, "HTTP", StringComparison.OrdinalIgnoreCase) Then
                    '
                    ' Controllo se HEAD
                    '
                    If dependency.Success = True AndAlso dependency.Data.StartsWith("HEAD") Then
                        Return
                    End If

                End If
            End If

        ElseIf TypeOf item Is RequestTelemetry Then
            '
            ' Tipo RequestTelemetry
            '
            Dim request = TryCast(item, RequestTelemetry)
            If request IsNot Nothing Then
                '
                ' Controllo se HEAD
                '
                If request.Success = True AndAlso request.Name.StartsWith("HEAD") Then
                    Return
                End If
            End If

        ElseIf TypeOf item Is ExceptionTelemetry Then
            '
            ' Tipo ExceptionTelemetry
            '
            Dim exception = TryCast(item, ExceptionTelemetry)
            If exception IsNot Nothing Then
                '
                ' Tipo FaultException
                '
                If TypeOf exception.Exception Is FaultException(Of DataFault) Then

                    Dim exDataFault = TryCast(exception.Exception, FaultException(Of DataFault))
                    '
                    ' Non traccio DataFault di tipo ErrorCode.DataRequestNotFoundObject
                    '
                    If exDataFault.Detail.Code = ErrorCode.DataRequestNotFoundObject Then
                        Return
                    End If

                End If

            End If
        End If

        _Next.Process(item)
    End Sub

End Class
