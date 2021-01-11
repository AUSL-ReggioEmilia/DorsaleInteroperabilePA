Public Class Config
    '
    ' Contenitore delle configurazioni da creare globalmente
    ' nella classe GlobalConfig
    '

    Friend Sub New()
        '
        ' Non deve errere inizializzato all'esterno della DLL direttamente
        ' ma tramite solo GlobalConfig
        '
    End Sub

    Public Property ConnectionString As String = Nothing
    Public Property LogSource As String = Nothing
    Public Property LogError As Boolean = True
    Public Property LogWarning As Boolean = True
    Public Property LogInformation As Boolean = False
    Public Property DatabaseIsolationLevel As Data.IsolationLevel = Data.IsolationLevel.ReadCommitted

End Class

Public NotInheritable Class ConfigSingleton
    '
    ' Crea la singola istanza
    ' NotInheritable per garantire l'univocità
    '
    Private Shared ReadOnly _Config As Config = New Config

    Shared Sub New()
    End Sub


#Region "Propietà"

    Public Shared ReadOnly Property Config As Config
        Get
            Return _Config
        End Get
    End Property

    Public Shared Property ConnectionString As String
        Get
            Return _Config.ConnectionString
        End Get
        Set
            _Config.ConnectionString = Value
        End Set
    End Property

    Public Shared Property LogSource As String
        Get
            Return _Config.LogSource
        End Get
        Set
            _Config.LogSource = Value
        End Set
    End Property

    Public Shared Property LogError As Boolean
        Get
            Return _Config.LogError
        End Get
        Set
            _Config.LogError = Value
        End Set
    End Property

    Public Shared Property LogWarning As Boolean
        Get
            Return _Config.LogWarning
        End Get
        Set
            _Config.LogWarning = Value
        End Set
    End Property

    Public Shared Property LogInformation As Boolean
        Get
            Return _Config.LogInformation
        End Get
        Set
            _Config.LogInformation = Value
        End Set
    End Property


    Public Shared Property DatabaseIsolationLevel As Data.IsolationLevel
        Get
            Return _Config.DatabaseIsolationLevel
        End Get
        Set
            _Config.DatabaseIsolationLevel = Value
        End Set
    End Property

#End Region

End Class

