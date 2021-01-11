Imports System
Imports System.Diagnostics
Imports System.Text
Imports System.Net
Imports System.Web.Services.Protocols
Imports Microsoft.ApplicationInsights
Imports System.Collections.Generic

Namespace DI.OrderEntry.User


    Public NotInheritable Class ExceptionsManager

        Private Shared WebServiceCantProcessRequest As String = "Il server è impossibilitato a processare la richiesta"
        Private Shared WebServiceFaultException As String = "Il server è impossibilitato a processare la richiesta, la richiesta è fallita."
        Private Shared WebServiceGenericError As String = "Si è verificato un errore nella chiamata al server."
        Private Shared WebServiceNotFound As String = "Il server è fuori servizio o è stato fornito un url non corretto."
        Private Shared WebServiceNotResponding As String = "Il server è fuori servizio."
        Private Shared WebServiceTimeOut As String = "La chiamata al server è andata in timeout."
        Private Shared WebServiceUserNotAuthenticated As String = "L'utente non è stato riconosciuto dal server."

        Private Sub New()
        End Sub

        ''' <summary>
        ''' Scrive nel log un'eccezione formattata con tipo messaggio "Error"
        ''' </summary>
        ''' <param name="exception">L'oggetto Exception da loggare</param>
        ''' <remarks></remarks>
        Public Shared Sub TraceException(ByVal exception As Exception)
            '
            ' MODIFICA ETTORE 2019-10-24: Aggiunto anche il controllo "If exception Is Nothing Then"
            '
            If exception Is Nothing Then
                Throw New ArgumentNullException("exception")
            End If
            '
            ' MODIFICA ETTORE 2019-10-24: se exception=ThreadAbortException non faccio nulla
            '
            If TypeOf exception Is Threading.ThreadAbortException Then
                Exit Sub
            End If
            '
            ' Scrivo in event log
            '
            TraceException(exception, TraceEventType.Error)
            '
            ' Gestisco l'errore su application insights
            '
            Dim dicProp As New Dictionary(Of String, String)
            dicProp.Add("NomePortale", "OrderEntry User Bootstrap")
            Dim ai = New TelemetryClient()
            ai.TrackException(exception, dicProp)
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

        '<summary>
        'Gestisce le eccezioni eventualmente generate da una chiamata ad un Web Service
        '</summary>
        '<param name="ex"></param>
        '<remarks></remarks>
        Public Shared Function ManageWebServiceException(ByVal ex As Exception) As String

            Dim errorMessage As New StringBuilder

            errorMessage.Append("Si è verificato un errore nella ricerca: ")

            Dim webException As WebException = TryCast(ex, WebException)

            If webException IsNot Nothing Then

                If webException.Response IsNot Nothing Then

                    Dim code As HttpStatusCode = DirectCast(DirectCast(webException.Response, WebResponse), HttpWebResponse).StatusCode

                    Select Case code
                        Case HttpStatusCode.RequestTimeout
                            errorMessage.Append(WebServiceTimeOut)
                        Case HttpStatusCode.GatewayTimeout
                            errorMessage.Append(WebServiceTimeOut)
                        Case HttpStatusCode.Unauthorized, HttpStatusCode.Forbidden, HttpStatusCode.ProxyAuthenticationRequired
                            errorMessage.Append(WebServiceUserNotAuthenticated)
                        Case HttpStatusCode.ServiceUnavailable, HttpStatusCode.NotFound
                            errorMessage.Append(WebServiceNotFound)
                        Case Else
                            errorMessage.Append(WebServiceGenericError)
                    End Select
                Else
                    errorMessage.Append(WebServiceNotResponding)
                End If
            Else
                errorMessage.Append(WebServiceGenericError)
            End If

            errorMessage.AppendLine()

            Dim faultException As ServiceModel.FaultException = TryCast(ex, ServiceModel.FaultException)
            If faultException IsNot Nothing Then
                errorMessage.Append(WebServiceFaultException)
                errorMessage.AppendLine()
            End If

            Dim soapException As SoapException = TryCast(ex, SoapException)
            If soapException IsNot Nothing Then
                errorMessage.Append(WebServiceCantProcessRequest)
                errorMessage.AppendLine()
            End If

            Return errorMessage.ToString

        End Function

    End Class

End Namespace