Imports System
Imports System.Diagnostics
Imports System.Text
Imports System.Net
Imports System.Web.Services.Protocols


Namespace DI.Sac.User

    Public NotInheritable Class ExceptionsManager

        Private Sub New()
        End Sub

        ''' <summary>
        ''' Scrive nel log un'eccezione formattata con tipo messaggio "Error"
        ''' </summary>
        ''' <param name="exception">L'oggetto Exception da loggare</param>
        ''' <remarks></remarks>
        Public Shared Sub TraceException(ByVal exception As Exception)
            TraceException(exception, TraceEventType.Error)
        End Sub

        ''' <summary>
        ''' Scrive nel log un'eccezione formattata 
        ''' </summary>
        ''' <param name="exception">L'oggetto Exception da loggare</param>
        ''' <param name="messageType">Il tipo di messaggio</param>
        ''' <remarks></remarks>
        Public Shared Sub TraceException(ByVal exception As Exception, ByVal messageType As TraceEventType)

            If exception Is Nothing Then
                Throw New ArgumentNullException("exception")
            End If

            Dim message As String = FormatException(exception)

            TraceMessage(message, messageType)
        End Sub

        ''' <summary>
        ''' Scrive nel log un messaggio non necessariamente generato da un'eccezione
        ''' </summary>
        ''' <param name="message">Il messaggio da loggare</param>
        ''' <param name="messageType">Il tipo di messaggio</param>
        ''' <remarks></remarks>
        Public Shared Sub TraceMessage(ByVal message As String, ByVal messageType As TraceEventType)

            My.Log.WriteEntry(message, messageType)
        End Sub

        ''' <summary>
        ''' Formatta il contenuto di un'eccezione in un oggetto Stringa
        ''' </summary>
        ''' <param name="exception">L'eccezione il cui contenuto formattare</param>
        ''' <returns>Un oggetto String contenente il testo dell'eccezione</returns>
        ''' <remarks></remarks>
        Public Shared Function FormatException(ByVal exception As Exception) As String

            If exception Is Nothing Then
                Throw New ArgumentNullException("exception")
            End If

            Dim result As New StringBuilder()
            Dim currentException As Exception = exception

            While currentException IsNot Nothing

                result.AppendLine(currentException.GetType().ToString())
                result.AppendLine(currentException.Message)
                result.AppendLine(currentException.StackTrace)

                currentException = currentException.InnerException
            End While

            Return result.ToString()
        End Function

    End Class

End Namespace