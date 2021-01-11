﻿Imports System
Imports System.Web
Imports Microsoft.VisualBasic.Constants
Imports System.Data
Imports System.Configuration
Imports Microsoft.ApplicationInsights

'--------------------------------------------------------------------------------------------------------------------------------------------
'
' IL MODULO SERVE A CENTRALIZZARE LA GESTIONE DEGLI ERRORI SIA PER QUANTO RIGUARDA IL LOG SU EVENTLOG
' CHE PER VISUALIZZARE UN MESSAGGIO COMPRENSIBILE ALL'UTENTE
'
' GESTISCE NEL CASO DI ECCEZIONI SQL L'UTILIZZO DELLE NUOVE FUNZIONALITA' DI LOG ERRORI SU DATABASE:
' IMPLEMENTATE TRAMITE LA TABELLA "ErrorLog" E LE SP "LogError","PrintError","RaiseErrorByIdLog"
' (tale implementazione non è comunque necessaria in generale)
'
' ULTIMA MODIFICA: 22/09/2016
'
'--------------------------------------------------------------------------------------------------------------------------------------------
Module GestioneErrori

    ''' <summary>
    ''' Enumerazione degli errori Sql
    ''' </summary>
    ''' <remarks></remarks>
    Private Enum SqlExceptionNumbers '-----------OK
        ConnectionBroken = -1
        Timeout = -2
        InvalidObject = 208
        CannotInsertNullValue = 515
        ConstraintViolation = 547
        OutOfMemory = 701
        OutOfLocks = 1204
        DeadlockVictim = 1205
        LockRequestTimeout = 1222
        DuplicateKey = 2601
        DuplicatePrimaryKey = 2627
        FailedResumeTransaction = 3971
        ShutDownInProgress = 6005
        TimeoutWaitingForMemoryResource = 8645
        LowMemoryCondition = 8651
        Xml_CarattereNonValido = 9420
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
        result.AppendLine("Utente: " & HttpContext.Current.User.Identity.Name)
        result.AppendLine("Data: " & DateTime.Now())

        While exception IsNot Nothing
            result.AppendLine(exception.Message)
            result.AppendLine(exception.StackTrace)
            exception = exception.InnerException
        End While

        Return result.ToString()
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
        ' mi aspetto un messaggio interpretabile dall'utente e quindi lo restituisco così come è.
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
                sRet = "Memoria insufficiente."

            Case SqlExceptionNumbers.LockRequestTimeout
                sRet = "Si è verificato un errore di timeout."

            Case SqlExceptionNumbers.TimeoutWaitingForMemoryResource
                sRet = "Si è verificato un errore di timeout."

            Case SqlExceptionNumbers.LowMemoryCondition
                sRet = "Memoria insufficiente."

            Case SqlExceptionNumbers.DuplicateKey
                sRet = "Si è verificato un errore di chiave duplicata."

            Case SqlExceptionNumbers.DuplicatePrimaryKey
                sRet = "Si è verificato un errore di chiave duplicata."

            'Leo 2020-05-26: Aggiunto messaggio di errore SQL in caso di un campo NULL non valorizzato!
            Case SqlExceptionNumbers.CannotInsertNullValue
                sRet = Ex.Message

            Case SqlExceptionNumbers.InvalidObject
                sRet = "Un oggetto invocato non esiste."

            Case SqlExceptionNumbers.ConstraintViolation
                sRet = "Si è verificato un errore di integrità referenziale. " & Ex.Message

            Case Else
                '
                ' Se non ho ancora intercettato l'eccezione, intanto ritorno un messaggio di errore generico.
                ' Bisognerà intercettare l'eccezione all'interno della SP RaiseErrorByIdLog per definire
                ' un messaggio interpretabile dall'utente o aggiungere un altro numero di errore sql
                '
                sRet = "Si è verificato un errore. Contattare l'amministratore."

        End Select
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
        If exception Is Nothing Then Return friendlyDetails

        '
        ' Se non è un errore di Threading.ThreadAbortException scrivo nell'event log: questo messaggio è altamente specifico e non va mostrato all'utente
        '
        If Not (TypeOf exception Is Threading.ThreadAbortException) Then
            '
            ' Scrivo errore in EventLog
            '
            My.Log.WriteEntry(FormatException(exception), System.Diagnostics.TraceEventType.Error)
        End If
        '
        ' Scrivo l'errore su application insights
        '
        Try
            '
            'Gestisco l'errore su Application insights
            '
            Dim dicProp As New Dictionary(Of String, String)
            '
            'Aggiungo alla descrizione dell'errore su azure anche il nome del portale in cui si è generato.
            '
            dicProp.Add("NomePortale", CustomInitializer.Telemetry.MyTelemetryInitializer.RoleName)

            Dim ai = New TelemetryClient()
            ai.TrackException(exception, dicProp)
        Catch
        End Try
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
                Else
                    '
                    ' Altrimenti mostro un messaggio generico
                    '
                    friendlyDetails = " Errore sconosciuto, contattare l'amministratore."
                End If
            Else
                '
                ' Altrimenti mostro un messaggio generico
                '
                friendlyDetails = " Errore sconosciuto, contattare l'amministratore."
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


    ' VERSIONI CON I PARAMETRI PER LA STRING.FORMAT
    Public Sub WriteInformation(Message As String, ParamArray Formatargs() As Object)
        My.Log.WriteEntry(String.Format(Message, Formatargs), System.Diagnostics.TraceEventType.Information)
    End Sub

    Public Sub WriteWarning(Message As String, ParamArray Formatargs() As Object)
        My.Log.WriteEntry(String.Format(Message, Formatargs), System.Diagnostics.TraceEventType.Warning)
    End Sub

    Public Sub WriteException(Message As String, ParamArray Formatargs() As Object)
        My.Log.WriteEntry(String.Format(Message, Formatargs), System.Diagnostics.TraceEventType.Error)
    End Sub

End Module
