Imports Microsoft.ApplicationInsights.Channel
Imports Microsoft.ApplicationInsights.Extensibility
Imports OE.Core

Public Class TelemetryInitializer
    Implements ITelemetryInitializer

    Private Shared _InstrumentationKey As String = My.Settings.InstrumentationKey

    Private Shared _AppVer As String = GetType(TelemetryInitializer).Assembly.GetName().Version.ToString()

    Private Shared _MachineNameId As String = Environment.MachineName
    Private Shared _OperatingSystem As String = Environment.OSVersion.ToString()

    Public Sub New()
        DiagnosticsHelper.WriteDiagnostics($"TelemetryInitializer: new TelemetryInitializer().")
    End Sub

    Private Sub ITelemetryInitializer_Initialize(telemetry As ITelemetry) Implements ITelemetryInitializer.Initialize

        If Not String.IsNullOrEmpty(_InstrumentationKey) Then
            telemetry.Context.InstrumentationKey = _InstrumentationKey
        End If
        '
        ' Device
        '
        telemetry.Context.Device.Id = _MachineNameId
        telemetry.Context.Device.OperatingSystem = _OperatingSystem
        '
        ' Role e application version
        '
        telemetry.Context.Cloud.RoleName = "OE-DAE-Msg"
        telemetry.Context.Component.Version = _AppVer
        '
        ' Session and user
        '
        Try
            Dim sUserNameId As String = Nothing
            Dim sSessionId As String = Nothing

            Dim Identity = ServiceSecurityContext.Current?.PrimaryIdentity

            If Identity IsNot Nothing AndAlso Identity.IsAuthenticated Then
                sUserNameId = Identity.Name
            End If

            Dim Operation = OperationContext.Current
            If Operation IsNot Nothing Then
                sSessionId = Operation.SessionId
            End If

            telemetry.Context.Session.Id = sSessionId
            telemetry.Context.User.Id = sUserNameId

        Catch ex As Exception
        End Try

    End Sub


End Class

