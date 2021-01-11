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

    Public Property AziendeErogantiLista As System.Collections.Generic.List(Of String) = Nothing
    Public Property SistemiErogantiLista As DataTable = Nothing

End Class

Public NotInheritable Class ConfigSingleton
    '
    ' Crea la singola istanza
    ' NotInheritable per garantire l'univocità
    '
    Private Shared ReadOnly _Config As Config = New Config
    Private Shared _bInitializeSuccess As Boolean = False

    Shared Sub New()
    End Sub


    Private Shared Sub Initialize()
        Dim oAdapter As EpisodioAdapter = Nothing
        Try
            Try
                oAdapter = New EpisodioAdapter
                oAdapter.ConnectionOpen(My.Config.ConnectionString)

                '
                ' Carico la lista delle aziende (Uso l'adattatore dei referti)
                '
                Try
                    _Config.AziendeErogantiLista = oAdapter.AziendeErogantiLista()
                Catch ex As Exception
                    Throw New Exception("Errore durante il caricamento della lista delle Aziende Eroganti." & vbCrLf & ex.Message)
                End Try

                '
                ' Carico la lista dei sistemi eroganti (Uso l'adattatore dei referti)
                '
                Try
                    _Config.SistemiErogantiLista = oAdapter.SistemiErogantiLista()
                Catch ex As Exception
                    Throw New Exception("Errore durante il caricamento della lista dei Sistemi Eroganti." & vbCrLf & ex.Message)
                End Try

            Catch ex As Exception
                Throw
            End Try
            '
            ' Altre inizializzazioni...
            '

            '
            ' Se sono qui alla fine di tutte le inizializzazioni allora sono andate a buon fine
            '
            _bInitializeSuccess = True
        Catch ex As Exception
            _bInitializeSuccess = False
            Throw ex
        Finally
            '
            ' Chiude connessione se aperta
            '
            If Not oAdapter Is Nothing Then
                oAdapter.Dispose()
            End If
        End Try
    End Sub


#Region "Proprietà"

    Public Shared ReadOnly Property Config As Config
        Get
            If Not _bInitializeSuccess Then
                Call Initialize()
            End If
            Return _Config
        End Get
    End Property

    Public Shared Property AziendeErogantiLista As System.Collections.Generic.List(Of String)
        Get
            Return Config.AziendeErogantiLista
        End Get
        Set(value As System.Collections.Generic.List(Of String))
            Config.AziendeErogantiLista = value
        End Set
    End Property

    Public Shared ReadOnly Property SistemiErogantiLista As DataTable
        Get
            Return Config.SistemiErogantiLista
        End Get
    End Property


#End Region

End Class