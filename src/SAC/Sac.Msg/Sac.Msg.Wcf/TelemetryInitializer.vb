Imports System.Security.Principal
Imports Microsoft.ApplicationInsights.Channel
Imports Microsoft.ApplicationInsights.Extensibility

Public Class TelemetryInitializer
    Implements ITelemetryInitializer

    'Da usare solo se salvato nel Web.config
    Private Shared _InstrumentationKey As String = My.Settings.InstrumentationKey

    'Legge dati di contesto una sola volta
    Private Shared _AppName As String = "SAC-DAE-Msg"
    Private Shared _AppVer As String = GetType(TelemetryInitializer).Assembly.GetName().Version.ToString()
    Private Shared _MachineNameId As String = Environment.MachineName
    Private Shared _OperatingSystem As String = Environment.OSVersion.ToString()

    Private Sub ITelemetryInitializer_Initialize(telemetry As ITelemetry) Implements ITelemetryInitializer.Initialize

        If String.IsNullOrEmpty(telemetry.Context.Cloud.RoleName) Then

            'KEY se valorizzata
            If Not String.IsNullOrEmpty(_InstrumentationKey) Then telemetry.Context.InstrumentationKey = _InstrumentationKey

            'Dati del computer
            telemetry.Context.Device.Id = _MachineNameId
            telemetry.Context.Device.OperatingSystem = _OperatingSystem

            'Role e version
            telemetry.Context.Cloud.RoleName = _AppName
            telemetry.Context.Component.Version = _AppVer

            'Dati dello USER e SESSION 
            Try
                Dim sUserNameId As String = Nothing
                Dim sSessionId As String = Nothing

                Dim Identity As IIdentity = ServiceSecurityContext.Current?.PrimaryIdentity
                If Identity IsNot Nothing AndAlso Identity.IsAuthenticated Then sUserNameId = ServiceSecurityContext.Current.PrimaryIdentity.Name

                Dim Operation As OperationContext = OperationContext.Current
                If Operation IsNot Nothing Then sSessionId = Operation.SessionId

                telemetry.Context.Session.Id = sSessionId
                telemetry.Context.User.Id = sUserNameId
            Catch
            End Try

        End If
    End Sub

End Class