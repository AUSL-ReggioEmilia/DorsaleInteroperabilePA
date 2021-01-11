Imports System.Text
Imports System.ServiceModel

Imports Msg = OE.Core.Schemas.Msg
Imports Microsoft.VisualBasic.CompilerServices
Imports System.Threading

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Imports Wcf = OE.Core.Schemas.Wcf12
#Else
'Versione 1.0 e 1.1
Imports Wcf = OE.Core.Schemas.Wcf
#End If

Public Class DiagnosticsHelper

#Region " Message error "

    Private Const ARGUMENT_NULL_FAULT As String = "Il parametro {0} non può essere vuoto o null!"
    Private Const ARGUMENT_FORMAT_GUID_FAULT As String = "Il parametro {0} non è correttamente formattato (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)! Valore={1}"
    Private Const ARGUMENT_FORMAT_IDOE_FAULT As String = "Il parametro {0} non è correttamente formattato (anno/numero)! Valore={1}"
    Private Const ARGUMENT_OUT_RANGE_FAULT As String = "Il parametro {0} è fuori dal range consentito! Valore={1}"

    Private Const TOKEN_VALIDATION_FAULT As String = "Errore di autenticazione. Token di accesso non valido."

#End Region

#Region " Events "


    Public Class EntryLogWrittenEventArgs
        Inherits EventArgs

        Public Property Message As String
        Public Property EntryType As EventLogEntryType
        Public Property Ex As Exception
        Public Property ThreadID As Integer = Thread.CurrentThread.ManagedThreadId
    End Class

    Public Shared Event EntryLogWritten As EventHandler(Of EntryLogWrittenEventArgs)

    Public Class TraceWrittenEventArgs
        Inherits EventArgs

        Public Property Message As String
        Public Property ThreadID As Integer = Thread.CurrentThread.ManagedThreadId
    End Class

    Public Shared Event TraceWritten As EventHandler(Of TraceWrittenEventArgs)

#End Region

    '
    ' NECESSARIO che ConfigurationHelper sia inizializzato immediatamente prima di ogni 
    ' altro metodi di DiagnosticsHelper
    ' **** Saranno letti solo la prima volta ****
    '
    Private Shared LogSource As String = ConfigurationHelper.LogSource
    Private Shared LogInformation As Boolean = ConfigurationHelper.LogInformation
    Private Shared LogWarning As Boolean = ConfigurationHelper.LogWarning
    Private Shared LogError As Boolean = ConfigurationHelper.LogError
    Private Shared LogTrace As Boolean = ConfigurationHelper.LogTrace

    ''' <summary>
    ''' Crea l'origine eventi valida per la scrittura di voci in un log del computer specificato.
    ''' </summary>
    Public Shared Sub CreateEventSource()

        If String.IsNullOrEmpty(LogSource) Then
            Throw New ArgumentNullException("Settings.LogSource")
        End If

        If Not EventLog.SourceExists(LogSource) Then
            EventLog.CreateEventSource(LogSource, "Application")
        End If
    End Sub

    ''' <summary>
    ''' Scrive nel log eventi una voce relativa a informazioni utilizzando l'origine eventi registrata specificata.
    ''' </summary>
    Public Shared Sub WriteInformation(ByVal message As String)
        Try
            '
            ' Scrivo nel Trace
            '
            WriteTrace(message)
            '
            ' Scrivo Info nel EventLog
            '
            If LogInformation Then
                EventLog.WriteEntry(LogSource, message, EventLogEntryType.Information)
            End If
            '
            ' Chiama evento esterno
            '
            Dim Args As New EntryLogWrittenEventArgs() With {.Message = message, .EntryType = EventLogEntryType.Information}
            RaiseEvent EntryLogWritten(Nothing, Args)

        Catch ex As Exception
            Trace.WriteLine(String.Concat(DateTime.Now, " - Errore durante DiagnosticsHelper.WriteInformation()", ex.Message))
        End Try
    End Sub

    ''' <summary>
    ''' Scrive nel log eventi una voce relativa a avvisi utilizzando l'origine eventi registrata specificata.
    ''' </summary>
    Public Shared Sub WriteWarning(ByVal message As String)

        Try
            '
            ' Scrivo nel Trace
            '
            WriteTrace(message)
            '
            ' Scrivo warning nel EventLog
            '
            If LogWarning Then
                EventLog.WriteEntry(LogSource, message, EventLogEntryType.Warning)
            End If
            '
            ' Chiama evento esterno
            '
            Dim Args As New EntryLogWrittenEventArgs() With {.Message = message, .EntryType = EventLogEntryType.Warning}
            RaiseEvent EntryLogWritten(Nothing, Args)

        Catch ex As Exception
            Trace.WriteLine(String.Concat(DateTime.Now, " - Errore durante DiagnosticsHelper.WriteWarning()", ex.Message))
        End Try

    End Sub

    Public Shared Sub WriteWarning(ByVal exception As Exception)
        WriteWarning(exception, Nothing)
    End Sub

    Public Shared Sub WriteWarning(ByVal exception As Exception, message As String)

        Try
            '
            ' Dettaglio dell'errore
            '
            Dim messageTitle As String = If(String.IsNullOrEmpty(message), exception.Message, $"{message}: {exception.Message}")
            Dim messageException As String = FormatException(exception)
            '
            ' Scrivo nel Trace
            '
            WriteTrace($"{messageTitle}{Environment.NewLine}{messageException}")
            '
            ' Scrivo warning nel EventLog
            '
            If LogWarning Then

                If TypeOf exception Is FaultException(Of DataFault) Then
                    messageTitle &= $"{Environment.NewLine} Fault Detail: {DirectCast(exception, FaultException(Of DataFault)).Detail.Message}"
                End If

                EventLog.WriteEntry(LogSource, $"{messageTitle}{Environment.NewLine}{messageException}", EventLogEntryType.Warning)
            End If
            '
            ' Chiama evento esterno
            '
            Dim Args As New EntryLogWrittenEventArgs() With {.Message = messageTitle, .EntryType = EventLogEntryType.Warning, .Ex = exception}
            RaiseEvent EntryLogWritten(Nothing, Args)

        Catch ex As Exception
            Trace.WriteLine(String.Concat(DateTime.Now, " - Errore durante DiagnosticsHelper.WriteWarning()", ex.Message))
        End Try
    End Sub

    ''' <summary>
    ''' Scrive nel log eventi una voce relativa a errori utilizzando l'origine eventi registrata specificata.
    ''' </summary>
    Public Shared Sub WriteError(ByVal exception As FaultException)
        '
        ' NON usata in MSG
        ' Non chiama Evento perche usa sempre altre func Write.....
        '
        Try
            Dim message As String

            If TypeOf exception Is FaultException(Of DataFault) Then

                'Dettaglio se DataFault
                Dim exFault As FaultException(Of DataFault) = DirectCast(exception, FaultException(Of DataFault))
                message = exFault.Detail.ToString

                'Scrivo errore nel EventLog
                WriteWarning(message)

            ElseIf TypeOf exception Is FaultException(Of ServiceFault) Then

                'Dettaglio se ServiceFault
                Dim exFault As FaultException(Of ServiceFault) = DirectCast(exception, FaultException(Of ServiceFault))
                message = exFault.Detail.ToString

                'Scrivo errore nel EventLog
                WriteError(message)

            ElseIf TypeOf exception Is FaultException(Of ArgumentFault) Then

                'Dettaglio se ArgumentFault
                Dim exFault As FaultException(Of ArgumentFault) = DirectCast(exception, FaultException(Of ArgumentFault))
                message = exFault.Detail.ToString

                'Scrivo errore nel EventLog
                WriteError(message)

            ElseIf TypeOf exception Is FaultException(Of TokenFault) Then

                'Dettaglio se TokenFault
                Dim exFault As FaultException(Of TokenFault) = DirectCast(exception, FaultException(Of TokenFault))
                message = exFault.Detail.ToString

                'Scrivo errore nel EventLog
                WriteError(message)
            Else
                'Dettaglio errore generico
                message = exception.Message

                'Scrivo errore nel EventLog
                WriteError(message)
            End If

        Catch ex As Exception
            Trace.WriteLine($"{DateTime.Now:hh:mm:ss.fff} - Errore durante DiagnosticsHelper.WriteError(FaultException)! {ex.Message}")
        End Try

    End Sub

    Public Shared Sub WriteError(ByVal exception As Exception)
        WriteError(exception, Nothing)
    End Sub

    Public Shared Sub WriteError(ByVal exception As Exception, message As String)
        Try
            '
            ' Dettaglio dell'errore
            '
            Dim messageTitle As String = If(String.IsNullOrEmpty(message), exception.Message, $"{message}: {exception.Message}")
            Dim messageException As String = FormatException(exception)
            '
            ' Scrivo nel trace
            '
            WriteTrace($"{messageTitle}{Environment.NewLine}{messageException}")
            '
            ' Scrivo errore nel EventLog
            '
            If LogError Then
                EventLog.WriteEntry(LogSource, $"{messageTitle}{Environment.NewLine}{messageException}", EventLogEntryType.Error)
            End If
            '
            ' Chiama evento esterno
            '
            Dim Args As New EntryLogWrittenEventArgs() With {.Message = messageTitle, .EntryType = EventLogEntryType.Error, .Ex = exception}
            RaiseEvent EntryLogWritten(Nothing, Args)

        Catch ex As Exception
            Trace.WriteLine($"{DateTime.Now:hh:mm:ss.fff} - Errore durante DiagnosticsHelper.WriteError()! {ex.Message}")
        End Try

    End Sub

    Private Shared Sub WriteError(ByVal message As String)

        Try
            'Scrivo nel trace
            '
            WriteTrace(message)
            '
            ' Scrivo errore nel EventLog
            '
            If LogError Then
                EventLog.WriteEntry(LogSource, message, EventLogEntryType.Error)
            End If
            '
            ' Chiama evento esterno
            '
            Dim Args As New EntryLogWrittenEventArgs() With {.Message = message,
                                                        .EntryType = EventLogEntryType.Error,
                                                        .Ex = New ApplicationException(message)}
            RaiseEvent EntryLogWritten(Nothing, Args)

        Catch ex As Exception
            Trace.WriteLine(String.Concat(DateTime.Now, " - Errore durante DiagnosticsHelper.WriteError(String)", ex.Message))
        End Try

    End Sub

    ''' <summary>
    ''' Scrive le informazioni sulla traccia nei listener di traccia dell'insieme Listeners.
    ''' </summary>
    Public Shared Sub WriteDiagnostics(ByVal message As String)
        Try
            '
            ' Scrivo nel Trace
            '
            WriteTrace(message)
            '
            ' Chiama evento esterno
            '
            Dim Args As New TraceWrittenEventArgs() With {.Message = message}
            RaiseEvent TraceWritten(Nothing, Args)
        Catch
            Trace.WriteLine($"{DateTime.Now:hh:mm:ss.fff} - Errore durante DiagnosticsHelper.WriteDiagnostics()")
        End Try
    End Sub

    Private Shared Sub WriteTrace(ByVal message As String)
        If LogTrace Then
            Trace.WriteLine($"{DateTime.Now:hh:mm:ss.fff} - {message}", LogSource)
        End If
    End Sub

    ''' <summary>
    ''' Formatta il testo della eccezione con i dati dell'errore
    ''' </summary>
    Public Shared Function FormatException(ByVal exception As Exception) As String

        If exception Is Nothing Then
            Return Nothing
        End If

        Dim result As New StringBuilder()
        Dim currentException As Exception = exception

        While currentException IsNot Nothing
            'Dettaglio della Ex
            result.AppendLine(currentException.GetType().ToString())
            result.AppendLine(currentException.Message)
            result.AppendLine(currentException.StackTrace)

            'Controllo annidamento
            currentException = currentException.InnerException

            'Salto una riga
            If currentException IsNot Nothing Then
                result.AppendLine()
            End If
        End While

        Return result.ToString()
    End Function

    ''' <summary>
    ''' Crea una FaultException tipo ServiceFault basata sull eccezione con i dati dell'errore
    ''' </summary>
    Public Shared Function GetServiceFault(ByVal exception As Exception, code As ErrorCode, AlsoWriteError As Boolean) As FaultException

        If exception Is Nothing Then
            Return Nothing
        End If

        ' Testo dell'errore
        Dim sReason As String = DiagnosticsHelper.FormatException(exception)

        'Scrive nel LOG
        If AlsoWriteError Then
            DiagnosticsHelper.WriteError(sReason)
        End If

        'Crea e ritorna il DataFault
        Return New FaultException(Of ServiceFault)(New ServiceFault(exception, code), sReason)

    End Function

    ''' <summary>
    ''' Crea una FaultException tipo DataFault basata sull eccezione con i dati dell'errore
    ''' </summary>
    Public Shared Function GetDataFault(ByVal exception As Exception, code As ErrorCode, AlsoWriteError As Boolean) As FaultException

        If exception Is Nothing Then
            Return Nothing
        End If

        ' Testo dell'errore
        Dim sReason As String = DiagnosticsHelper.FormatException(exception)

        'Scrive nel LOG
        If AlsoWriteError Then
            DiagnosticsHelper.WriteError(sReason)
        End If

        'Crea e ritorna il DataFault
        Return New FaultException(Of DataFault)(New DataFault(exception, code), sReason)

    End Function

    Public Shared Function GetDataFault(ByVal message As String, code As ErrorCode, AlsoWriteError As Boolean) As FaultException

        'Scrive nel LOG
        If AlsoWriteError Then
            DiagnosticsHelper.WriteError(message)
        End If

        'Crea e ritorna il DataFault
        Return New FaultException(Of DataFault)(New DataFault(message, code), message)

    End Function

    ''' <summary>
    ''' Crea una FaultException tipo ArgumentFault basata sull eccezione con i dati dell'errore
    ''' </summary>
    Public Shared Function GetArgumentNullFault(ByVal paramName As String, AlsoWriteError As Boolean) As FaultException

        Dim sReason As String = String.Format(ARGUMENT_NULL_FAULT, paramName)

        'Scrive nel LOG
        If AlsoWriteError Then
            DiagnosticsHelper.WriteError(sReason)
        End If

        'Crea e ritorna il ArgumentFault
        Return New FaultException(Of ArgumentFault)(New ArgumentFault(sReason, ErrorCode.ArgumentNull), sReason)

    End Function

    Public Shared Function GetArgumentGuidFault(ByVal paramName As String, ByVal paramValue As String, AlsoWriteError As Boolean) As FaultException

        Dim sReason As String = String.Format(ARGUMENT_FORMAT_GUID_FAULT, paramName, paramValue)

        'Scrive nel LOG
        If AlsoWriteError Then
            DiagnosticsHelper.WriteError(sReason)
        End If

        'Crea e ritorna il ArgumentFault
        Return New FaultException(Of ArgumentFault)(New ArgumentFault(sReason, ErrorCode.ArgumentFormat), sReason)

    End Function

    Public Shared Function GetArgumentIdOrderEntryFault(ByVal paramName As String, ByVal paramValue As String, AlsoWriteError As Boolean) As FaultException

        Dim sReason As String = String.Format(ARGUMENT_FORMAT_IDOE_FAULT, paramName, paramValue)

        'Scrive nel LOG
        If AlsoWriteError Then
            DiagnosticsHelper.WriteError(sReason)
        End If

        'Crea e ritorna il ArgumentFault
        Return New FaultException(Of ArgumentFault)(New ArgumentFault(sReason, ErrorCode.ArgumentFormat), sReason)

    End Function

    Public Shared Function GetArgumentOutOfRangeFault(ByVal paramName As String, ByVal paramValue As String, AlsoWriteError As Boolean) As FaultException

        Dim sReason As String = String.Format(ARGUMENT_OUT_RANGE_FAULT, paramName, paramValue)

        'Scrive nel LOG
        If AlsoWriteError Then
            DiagnosticsHelper.WriteError(sReason)
        End If

        'Crea e ritorna il ArgumentFault
        Return New FaultException(Of ArgumentFault)(New ArgumentFault(sReason, ErrorCode.ArgumentOutOfRange), sReason)

    End Function


    ''' <summary>
    ''' Crea una FaultException tipo TokenFault basata sull eccezione con i dati dell'errore
    ''' </summary>
    Public Shared Function GetTokenValidationFault(ByVal tokenAccesso As Wcf.WsTypes.TokenAccessoType, AlsoWriteError As Boolean) As FaultException

        Dim sReason As String = String.Concat(TOKEN_VALIDATION_FAULT, "Utente: ", tokenAccesso.Utente)

        'Scrive nel LOG
        If AlsoWriteError Then
            DiagnosticsHelper.WriteError(sReason)
        End If

        'Crea e ritorna il TokenFault
        Return New FaultException(Of TokenFault)(New TokenFault(sReason, ErrorCode.UnauthorizedAccess), sReason)

    End Function

    Public Shared Function GetTokenFault(ByVal reason As String, AlsoWriteError As Boolean) As FaultException

        'Scrive nel LOG
        If AlsoWriteError Then
            DiagnosticsHelper.WriteError(reason)
        End If

        'Crea e ritorna il TokenFault
        Return New FaultException(Of TokenFault)(New TokenFault(reason, ErrorCode.UnauthorizedAccess), reason)

    End Function

End Class