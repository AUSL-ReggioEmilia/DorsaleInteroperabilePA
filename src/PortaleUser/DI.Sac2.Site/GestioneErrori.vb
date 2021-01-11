Imports System
Imports System.Web
Imports Microsoft.VisualBasic.Constants
Imports System.Data
Imports Microsoft.ApplicationInsights
'--------------------------------------------------------------------------------------------------------------------------------------------
'
' IL MODULO SERVE A CNTRALIZZARE LA GESTIONE DEGLI ERRORI SIA PER QUANTO RIGUARDA IL LOG SU EVENTLOG
' CHE PER VISUALIZZARE UN MESSAGGIO COMPRENSIBILE ALL'UTENTE
'
' GESTISCE NEL CASO DI ECCEZIONI SQL L'UTILIZZO DELLE NUOVE FUNZIONALITA' DI LOG ERRORI SU DATABASE:
' IMPLEMENTATE TRAMITE LA TABELLA "ErrorLog" E LE SP "LogError","PrintError","RaiseErrorByIdLog"
' (tale implementazione non è comunque necessaria in generale)
'--------------------------------------------------------------------------------------------------------------------------------------------
Module GestioneErrori

    ''' <summary>
    ''' Enumerazione degli errori Sql
    ''' </summary>
    ''' <remarks></remarks>
    Private Enum SqlExceptionNumbers '-----------OK
        ConnectionBroken = -1
        Timeout = -2
        DeadlockVictim = 1205
        ShutDownInProgress = 6005
        Xml_CarattereNonValido = 9420
        OutOfMemory = 701
        OutOfLocks = 1204
        LockRequestTimeout = 1222
        TimeoutWaitingForMemoryResource = 8645
        LowMemoryCondition = 8651
        DuplicateKey = 2601
        InvalidObject = 208
        FailedResumeTransaction = 3971
        'Numero errore di messaggio custom
        Custom50000 = 50000
    End Enum

    ''' <summary>
    ''' Formattazione di una eccezione
    ''' </summary>
    ''' <param name="exception"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function FormatException(ByVal exception As Exception) As String '----------------------OK
        If exception Is Nothing Then
            Throw New ArgumentNullException("exception")
        End If
        Dim result As New System.Text.StringBuilder()
        Dim currentException As Exception = exception

        While exception IsNot Nothing
            result.AppendLine(exception.Message)
            result.AppendLine(exception.StackTrace)
            exception = exception.InnerException
        End While
        Dim user As String = "Utente: " & HttpContext.Current.User.Identity.Name
        Dim data As String = "Data: " & DateTime.Now()
        Return user & vbCrLf & data & vbCrLf & result.ToString()
    End Function

    ''' <summary>
    ''' Gestione degli errori SQL
    ''' </summary>
    ''' <param name="Ex"></param>
    ''' <returns>Il messaggio di errore per l'utente</returns>
    ''' <remarks></remarks>
    Private Function GetSqlExceptionError(ByVal Ex As SqlClient.SqlException) As String '-------------------OK
        '----------------------------------------------------------------------------------------
        ' In caso di raise error di un custom message (senza definizione del numero di errore, quindi ex.number=50000)
        ' mi aspetto un messaggio interpretabile dall'utente e quindi lo restituisco cosi come è.
        '----------------------------------------------------------------------------------------
        ' Negli altri casi costruisco un messaggio comprensibile per l'utente
        '----------------------------------------------------------------------------------------
        Dim sRet As String = String.Empty
        Select Case Ex.Number
            Case SqlExceptionNumbers.Custom50000
                'Si presuppone che il messaggio sia comprensibile per l'utente
                sRet = Ex.Message

            Case SqlExceptionNumbers.Timeout
                sRet = "Si è verificato un errore di timeout."

            Case SqlExceptionNumbers.ConnectionBroken
                sRet = "Errore di connessione al database."

            Case SqlExceptionNumbers.DeadlockVictim
                sRet = "Si è verificato un errore di deadlock. Rieseguire la transazione."

            Case SqlExceptionNumbers.ShutDownInProgress
                sRet = "Shutdown in corso."

            Case SqlExceptionNumbers.Xml_CarattereNonValido
                sRet = "L'xml contiene caratteri non validi."

            Case SqlExceptionNumbers.OutOfMemory
                sRet = "Memoria insufficente."

            Case SqlExceptionNumbers.OutOfLocks
                sRet = "OutOfLocks."

            Case SqlExceptionNumbers.LockRequestTimeout
                sRet = "Si è verificato un errore di timeout."

            Case SqlExceptionNumbers.TimeoutWaitingForMemoryResource
                sRet = "Si è verificato un errore di timeout."

            Case SqlExceptionNumbers.LowMemoryCondition
                sRet = "Memoria insufficente."

            Case SqlExceptionNumbers.DuplicateKey
                sRet = "Si è verificato un errore di chiave duplicata."

            Case SqlExceptionNumbers.InvalidObject
                sRet = "Un oggetto invocato non esiste."

            Case SqlExceptionNumbers.FailedResumeTransaction
                sRet = "Errore in seguito al resume della transazione."
            Case Else
                sRet = String.Empty
        End Select
        '
        ' Se non ho ancora intercettato l'eccezione, intanto ritorno un messaggio di errore generico.
        ' Bisognerà intercettare l'eccezione all'interno della SP RaiseErrorByIdLog per definire
        ' un messaggio interpretabile dall'utente o aggiungere un altro numero di errore sql
        '
        If String.IsNullOrEmpty(sRet) Then
            sRet = "Si è verificato un errore. Contattare l'amministratore."
        End If
        '
        ' Restituisco il messagio per l'utente
        '
        Return sRet
    End Function


    ''' <summary>
    ''' Scrive nell'event log e restituisce un messaggio per l'utente da visualizzare in interfaccia
    ''' </summary>
    ''' <param name="exception"></param>
    ''' <returns>Il messaggio di errore per l'utente. Può restituire una stringa vuota.</returns>
    ''' <remarks></remarks>
    Public Function TrapError(exception As Exception) As String
        Dim friendlyDetails As String = String.Empty

        ' MODIFICA ETTORE 2019-10-24: Se è un errore di Threading.ThreadAbortException esco restituendo String.Empty (questo messaggio è altamente specifico e non va mostrato all'utente)
        If TypeOf exception Is Threading.ThreadAbortException Then
            Return String.Empty
        End If
        '
        ' Scrivo nell'event log
        '
        My.Log.WriteEntry(FormatException(exception), System.Diagnostics.TraceEventType.Error)
        Trace.TraceError("Di.PortalUser.Sac - Errore: " & FormatException(exception))
        '
        'Gestisco l'errore su Application insights
        '
        Dim dicProp As New Dictionary(Of String, String)
        'Aggiungo alla descrizione dell'errore su azure anche il nome del portale in cui si è generato.
        dicProp.Add("NomePortale", "SAC-User")
        'Traccio l'errrore.
        Dim ai = New TelemetryClient()
        ai.TrackException(exception, dicProp)


        '-----------------------------------------------------------------------------------------------
        ' QUI POSSO POI AGGIUNGERE EVENTUALI ECCEZIONI CUSTOM
        '-----------------------------------------------------------------------------------------------
        '
        ' Inizio l'identificazione dell'errore per scrivere un messaggio di dettaglio più o meno specifico a seconda delle eccezioni verificatesi
        '
        If TypeOf exception Is System.Data.DBConcurrencyException Then
            '
            ' Eccezione di tipo concorrenziale generata dal dataset
            '
            friendlyDetails = " Errore di concorrenza; aggiornare i dati e riprovare."

        ElseIf TypeOf exception Is SqlClient.SqlException Then
            '
            ' Eccezione di tipo Sql
            '
            Dim ex As SqlClient.SqlException = CType(exception, SqlClient.SqlException)
            friendlyDetails = GetSqlExceptionError(ex)

        ElseIf TypeOf exception Is ApplicationException Then
            '
            '  Eccezione Applicativa generata via codice 
            '
            friendlyDetails = exception.Message

        ElseIf TypeOf exception Is Threading.ThreadAbortException Then
            '
            ' Restituisco "". Il chiamante deve verificare se è presente il messaggio di errore prima di visualizzarlo.
            '
            friendlyDetails = String.Empty
        Else
            '-----------------------------------------------------------------------------------------------------
            ' Eccezione di tipo Generico: può essere dovuta al wrapping da parte dell'ObjectDataSource
            '-----------------------------------------------------------------------------------------------------
            '
            ' Se ho una inner exception, sarà sicuramente più specifica e loggo quella
            '
            If exception.InnerException IsNot Nothing Then
                If TypeOf exception.InnerException Is System.Data.DBConcurrencyException Then
                    '
                    ' Eccezione di tipo concorrenziale generata dal dataset
                    '
                    friendlyDetails = " Errore di concorrenza; aggiornare i dati e riprovare."
                ElseIf TypeOf exception.InnerException Is SqlClient.SqlException Then
                    '
                    ' Eccezione di tipo Sql
                    '
                    friendlyDetails = GetSqlExceptionError(DirectCast(exception.InnerException, SqlClient.SqlException))
                End If
            Else
                '
                ' Altrimenti mostro un messaggio generico
                '
                friendlyDetails = " Errore sconosciuto, contattare l'amministratore"
            End If

        End If
        '
        ' Restituisco il messaggio di errore per l'utente
        '
        Return friendlyDetails

    End Function


    Public Sub WriteException(ex As Exception)
        My.Log.WriteEntry(FormatException(ex), System.Diagnostics.TraceEventType.Error)
    End Sub

    Public Sub WriteException(Message As String)
        My.Log.WriteEntry(Message, System.Diagnostics.TraceEventType.Error)
    End Sub

    Public Sub WriteInformation(Message As String)
        My.Log.WriteEntry(Message, System.Diagnostics.TraceEventType.Information)
    End Sub

    Public Sub WriteWarning(Message As String)
        My.Log.WriteEntry(Message, System.Diagnostics.TraceEventType.Warning)
    End Sub

End Module
