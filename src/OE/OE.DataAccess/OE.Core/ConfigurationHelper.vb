Public NotInheritable Class ConfigurationHelper

    Public Shared Sub Initialize(setting As ConfigurationSettings)
        '
        ' Usata da OE.Msg
        '
        Dim currentSetting As ConfigurationSettings = My.OrderEntryConfig
        If currentSetting.Equals(setting) Then
            '
            ' Stesso oggetto non risetto
            '
            DiagnosticsHelper.WriteDiagnostics("ConfigurationHelper.Initialize(). Parameter setting Equals currentSetting!")
        End If
        '
        ' String connection e DB
        '
        currentSetting.ConnectionString = setting.ConnectionString
        currentSetting.TransactionIsolationLevel = IsolationLevel.ReadCommitted
        currentSetting.Ttl = 300
        '
        ' Log setting
        '
        currentSetting.LogSource = setting.LogSource
        currentSetting.LogTrace = setting.LogTrace
        currentSetting.LogInformation = setting.LogInformation
        currentSetting.LogWarning = setting.LogWarning
        currentSetting.LogError = setting.LogError
        '
        ' AutoSync setting
        '
        currentSetting.AutoSyncPrestazioni = setting.AutoSyncPrestazioni
        currentSetting.AutoSyncSistemiEroganti = setting.AutoSyncSistemiEroganti
        currentSetting.AutoSyncSistemiRichiedenti = setting.AutoSyncSistemiRichiedenti
        currentSetting.AutoSyncUnitaOperative = setting.AutoSyncUnitaOperative
        currentSetting.AutoSyncUtentiDelegati = setting.AutoSyncUtentiDelegati
        '
        ' Trascodifiche
        '
        currentSetting.TranscodificaAttiva = setting.TranscodificaAttiva
        '
        ' WS account
        '
        currentSetting.WsUserName = setting.WsUserName
        currentSetting.WsPassword = setting.WsPassword
        currentSetting.WsDomain = setting.WsDomain
        '
        ' Copio temporanea mente le opzioni
        '
        Dim settingOptionsCopy As Dictionary(Of String, String) = New Dictionary(Of String, String)
        If setting.Options IsNot Nothing AndAlso setting.Options.Any Then
            For Each o In setting.Options
                settingOptionsCopy.Add(o.Key, o.Value)
            Next
        End If
        '
        ' Cancello e riscrivo nel setting
        '
        Dim currentOption As Dictionary(Of String, String) = currentSetting.Options
        SyncLock currentOption
            '
            ' SINCRONIZZO scrittura
            '
            currentOption.Clear()

            If settingOptionsCopy IsNot Nothing AndAlso settingOptionsCopy.Any Then
                For Each o In settingOptionsCopy
                    currentOption.Add(o.Key, o.Value)
                Next
            End If

        End SyncLock

    End Sub

#Region "Propietà"

    Public Shared ReadOnly Property ConfigurationSettings As ConfigurationSettings
        Get
            Return My.OrderEntryConfig
        End Get
    End Property

    Public Shared ReadOnly Property ConnectionString As String
        Get
            Return My.OrderEntryConfig.ConnectionString
        End Get
    End Property

    Public Shared ReadOnly Property TransactionIsolationLevel As IsolationLevel
        Get
            Return My.OrderEntryConfig.TransactionIsolationLevel
        End Get
    End Property

    Public Shared ReadOnly Property Ttl As Integer
        Get
            Return My.OrderEntryConfig.Ttl
        End Get
    End Property

    Public Shared ReadOnly Property LogSource As String
        Get
            Return My.OrderEntryConfig.LogSource
        End Get
    End Property

    Public Shared ReadOnly Property LogInformation As Boolean
        Get
            Return My.OrderEntryConfig.LogInformation
        End Get
    End Property

    Public Shared ReadOnly Property LogWarning As Boolean
        Get
            Return My.OrderEntryConfig.LogWarning
        End Get
    End Property

    Public Shared ReadOnly Property LogError As Boolean
        Get
            Return My.OrderEntryConfig.LogError
        End Get
    End Property

    Public Shared ReadOnly Property LogTrace As Boolean
        Get
            Return My.OrderEntryConfig.LogTrace
        End Get
    End Property

    Public Shared ReadOnly Property AutoSyncPrestazioni As Boolean
        Get
            Return My.OrderEntryConfig.AutoSyncPrestazioni
        End Get
    End Property

    Public Shared ReadOnly Property AutoSyncUnitaOperative As Boolean
        Get
            Return My.OrderEntryConfig.AutoSyncUnitaOperative
        End Get
    End Property

    Public Shared ReadOnly Property AutoSyncSistemiRichiedenti As Boolean
        Get
            Return My.OrderEntryConfig.AutoSyncSistemiRichiedenti
        End Get
    End Property

    Public Shared ReadOnly Property AutoSyncSistemiEroganti As Boolean
        Get
            Return My.OrderEntryConfig.AutoSyncSistemiEroganti
        End Get
    End Property

    Public Shared ReadOnly Property AutoSyncUtentiDelegati As Boolean
        Get
            Return My.OrderEntryConfig.AutoSyncUtentiDelegati
        End Get
    End Property

    Public Shared ReadOnly Property TranscodificaAttiva As Boolean
        Get
            Return My.OrderEntryConfig.TranscodificaAttiva
        End Get
    End Property

    Public Shared ReadOnly Property WsUserName As String
        Get
            Return My.OrderEntryConfig.WsUserName
        End Get
    End Property

    Public Shared ReadOnly Property WsPassword As String
        Get
            Return My.OrderEntryConfig.WsPassword
        End Get
    End Property

    Public Shared ReadOnly Property WsDomain As String
        Get
            Return My.OrderEntryConfig.WsDomain
        End Get
    End Property

    Public Shared ReadOnly Property Options As Dictionary(Of String, String)
        Get
            Return My.OrderEntryConfig.Options
        End Get
    End Property

#End Region

#Region "GetOptionValue"

    Public Shared Function GetOptionValue(Key As String, DefaultValue As String) As String

        SyncLock Options
            '
            ' Sincronizzo LETTURA
            '
            If Options IsNot Nothing AndAlso Options.ContainsKey(Key) Then
                Return Options.Item(Key)
            Else
                Return DefaultValue
            End If

        End SyncLock

    End Function

    Public Shared Function GetOptionValue(Key As String, DefaultValue As Boolean) As Boolean

        SyncLock Options
            '
            ' Sincronizzo LETTURA
            '
            If Options IsNot Nothing AndAlso Options.ContainsKey(Key) Then

                Dim bValue As Boolean
                If Not Boolean.TryParse(Options.Item(Key), bValue) Then
                    bValue = False
                End If

                Return bValue
            Else
                Return DefaultValue
            End If

        End SyncLock

    End Function

    Public Shared Function GetOptionValue(Key As String, DefaultValue As Integer) As Integer

        SyncLock Options
            '
            ' Sincronizzo LETTURA
            '
            If Options IsNot Nothing AndAlso Options.ContainsKey(Key) Then

                Dim nValue As Integer
                If Not Integer.TryParse(Options.Item(Key), nValue) Then
                    nValue = 0
                End If

                Return nValue
            Else
                Return DefaultValue
            End If

        End SyncLock

    End Function

#End Region

End Class