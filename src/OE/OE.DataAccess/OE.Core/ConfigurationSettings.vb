Public Class ConfigurationSettings
    Friend Sub New()
        '
        ' Non deve errere inizializzato all'esterno del CORE direttamente
        ' ma tramite solo ConfigurationHelper
        '
    End Sub

    ''' <summary>
    ''' Ottiene o imposta settaggi database.
    ''' </summary>
    Public Property ConnectionString As String = Nothing
    Public Property TransactionIsolationLevel As IsolationLevel

    ''' <summary>
    ''' Ottiene o imposta il tempo di validita del ticket di autenticazione espresso in secondi.
    ''' </summary>
    Public Property Ttl As Integer

    ''' <summary>
    ''' Ottiene o imposta pre proprietà del EventLog
    ''' </summary>
    Public Property LogSource As String
    Public Property LogInformation As Boolean
    Public Property LogWarning As Boolean
    Public Property LogError As Boolean
    Public Property LogTrace As Boolean

    ''' <summary>
    ''' Abilitazioni per l'autopopolamento delle tabelle di base
    ''' </summary>
    Public Property AutoSyncPrestazioni As Boolean
    Public Property AutoSyncUnitaOperative As Boolean
    Public Property AutoSyncSistemiRichiedenti As Boolean
    Public Property AutoSyncSistemiEroganti As Boolean
    Public Property AutoSyncUtentiDelegati As Boolean

    ''' <summary>
    ''' Abilita la trascodifica delle UO
    ''' </summary>
    Public Property TranscodificaAttiva As Boolean

    ''' <summary>
    ''' Account per la connessione ai WS
    ''' </summary>
    Public Property WsUserName As String
    Public Property WsPassword As String
    Public Property WsDomain As String
    ''' <summary>
    ''' Altre opzioni
    ''' </summary>
    ''' 
    Public ReadOnly Property Options As New Dictionary(Of String, String)

End Class