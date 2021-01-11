Imports System.Text
Imports System.Diagnostics
Imports System.Xml
Imports OE.Core
Imports System.Threading

Friend Class Helper

    Friend Shared Function InitCoreConfigurationSettings() As OE.Core.ConfigurationSettings
        '
        ' Per non modificare tutto il codice ma agire per passi ora non
        ' sarebbe più necessario ritornare ConfigurationSettings e passrlo ai metodi
        ' della OE.Msg.DataAccess, il GLOBALONE del CORE è già init
        '
        ' Prossime modifiche rimuoveremo il parametro setting, perchè è già globale

        '
        ' Instanza del globalone su OE.Core.ConfigurationHelper
        '
        Dim oSetting As OE.Core.ConfigurationSettings
        oSetting = OE.Core.ConfigurationHelper.ConfigurationSettings
        '
        ' String connection e DB
        '
        oSetting.ConnectionString = My.Settings.ConnectionString
        oSetting.TransactionIsolationLevel = IsolationLevel.ReadCommitted
        oSetting.Ttl = 300
        '
        ' Log setting
        '
        oSetting.LogSource = My.Settings.LogSource

        If Not Boolean.TryParse(My.Settings.LogTrace, oSetting.LogTrace) Then
            oSetting.LogTrace = False
        End If
        If Not Boolean.TryParse(My.Settings.LogInformation, oSetting.LogInformation) Then
            oSetting.LogInformation = False
        End If
        If Not Boolean.TryParse(My.Settings.LogWarning, oSetting.LogWarning) Then
            oSetting.LogWarning = False
        End If
        If Not Boolean.TryParse(My.Settings.LogError, oSetting.LogError) Then
            oSetting.LogError = False
        End If
        '
        ' AutoSync setting
        '
        oSetting.AutoSyncPrestazioni = My.Settings.AutoSyncPrestazioni
        oSetting.AutoSyncSistemiEroganti = My.Settings.AutoSyncSistemiEroganti
        oSetting.AutoSyncSistemiRichiedenti = My.Settings.AutoSyncSistemiRichiedenti
        oSetting.AutoSyncUnitaOperative = My.Settings.AutoSyncUnitaOperative
        oSetting.AutoSyncUtentiDelegati = My.Settings.AutoSyncUtentiDelegati
        '
        ' Trascodifiche
        '
        oSetting.TranscodificaAttiva = My.Settings.TranscodificaAttiva
        '
        ' WS account
        '
        oSetting.WsUserName = My.Settings.WsUserName
        oSetting.WsPassword = My.Settings.WsPassword
        oSetting.WsDomain = My.Settings.WsDomain
        '
        ' Opzioni
        '
        SyncLock oSetting.Options

            oSetting.Options.Clear()
            oSetting.Options.Add("IgnoraRegimeVuoto", My.Settings.IgnoraRegimeVuoto.ToString)

        End SyncLock
        '
        ' Solo in debug traccio le configurazioni
        '
#If DEBUG Then
        DiagnosticsHelper.WriteDiagnostics($"ConfigurationSettings: {Helper.GetDataXml(oSetting)}")
#Else
        DiagnosticsHelper.WriteDiagnostics($"ConfigurationSettings initialized!")
#End If

        Return oSetting

    End Function

    Friend Shared Function GetDataXml(Of T)(ByVal value As T) As String

        Try
            Using stream As New IO.MemoryStream
                Dim oDataSerializer As New DataContractSerializer(GetType(T))
                oDataSerializer.WriteObject(stream, value)

                stream.Position = 0
                Return System.Text.Encoding.UTF8.GetString(stream.ToArray)
            End Using

        Catch ex As Exception
            Return ex.Message
        End Try

    End Function

    Friend Shared Function CheckConnectionString(ByVal ConnectionString As String) As String
        '
        ' Verifica la connessione al DB
        '
        Dim oCheckDbConn As SqlClient.SqlConnection = Nothing

        Try
            oCheckDbConn = New SqlClient.SqlConnection(ConnectionString)
            If oCheckDbConn IsNot Nothing Then
                '
                ' Apro
                '
                oCheckDbConn.Open()
                Return "ServerVersion=" & oCheckDbConn.ServerVersion
            Else
                Throw New Exception("New SqlClient.SqlConnection failed!")
            End If

        Catch ex As Exception
            '
            ' Error
            '
            Throw

        Finally
            '
            ' Chiudo connessione di check
            '
            If oCheckDbConn IsNot Nothing Then
                oCheckDbConn.Close()
                oCheckDbConn.Dispose()
            End If

        End Try

    End Function

    Friend Shared Sub TryConnectToDatabase(oSetting As OE.Core.ConfigurationSettings)
        '
        ' Prova a connetersi
        '
        For nRetry As Integer = 0 To My.Settings.RetryCount
            Try
                If nRetry > 0 Then
                    '
                    ' Log info e seconto o più
                    '
                    DiagnosticsHelper.WriteInformation(String.Format("Riprova numero {0} Check SqlConnection!", nRetry))
                End If

                Dim sResult As String = Helper.CheckConnectionString(oSetting.ConnectionString)
                DiagnosticsHelper.WriteInformation("Check SqlConnection: " & sResult)
                '
                ' Se processato esce dal loop
                '
                Exit For

            Catch ex As Exception
                '
                ' Error
                '
                DiagnosticsHelper.WriteError(ex, "Errore durante DataAccess.CheckConnectionString()!")
                '
                ' Errore su connessione
                '
                If nRetry = My.Settings.RetryCount Then
                    '
                    ' Custom error
                    '
                    Throw New ApplicationException("NetError: Connessione al database!", ex)
                Else
                    '
                    ' Aspetta
                    '
                    Dim nRetryTime As Integer = My.Settings.WaitAfterNetError
                    If nRetryTime < 0 Then
                        nRetryTime = 0
                    End If
                    Thread.Sleep(nRetryTime)
                End If
            End Try
        Next
    End Sub

    Friend Shared ReadOnly Property AppInsightsEventLog() As Boolean = My.Settings.AppInsightsEventLog
    Friend Shared ReadOnly Property AppInsightsTrace() As Boolean = My.Settings.AppInsightsTrace
    Friend Shared ReadOnly Property AppInsightsDependecyMinDuration() As Integer = My.Settings.AppInsightsDependecyMinDuration

End Class
