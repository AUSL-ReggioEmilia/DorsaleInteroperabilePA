Imports System.Diagnostics
Imports System.Configuration
Imports Microsoft.ApplicationInsights

Public Class Logging

    Public Shared Sub WriteInformation(ByVal DescOperation As String)
        '
        ' Scrive l'errore passato
        '
        Dim oAppSettings As Specialized.NameValueCollection = ConfigurationManager.AppSettings

        Dim boolWriteEV As Boolean
        Try
            boolWriteEV = CType(oAppSettings("EventLog.Information"), Boolean)
        Catch ex As Exception
            boolWriteEV = False
        End Try

        If boolWriteEV Then
            '
            ' Log Source
            '
            Dim rstrLogName As String
            Try
                rstrLogName = CType(oAppSettings("EventLog.Application"), String)
            Catch ex As Exception
                rstrLogName = "Application"
            End Try
            '
            ' Aggiungo info utente
            '
            'DescOperation = "Utente: " & HttpContext.Current.User.Identity.Name & vbCrLf & _
            '            DescOperation
            Dim sUtente As String = String.Empty
            Try
                sUtente = "Utente: " & HttpContext.Current.User.Identity.Name & vbCrLf
            Catch ex As Exception
            End Try
            DescOperation = sUtente & DescOperation
            '
            ' Scrivo errore
            '
            EventLog.WriteEntry(rstrLogName, DescOperation, EventLogEntryType.Information)
        End If

    End Sub

    Public Shared Sub WriteWarning(ByVal DescOperation As String)
        '
        ' Scrive l'errore passato
        '
        Dim oAppSettings As Specialized.NameValueCollection = ConfigurationManager.AppSettings

        Dim boolWriteEV As Boolean
        Try
            boolWriteEV = CType(oAppSettings("EventLog.Warning"), Boolean)
        Catch ex As Exception
            boolWriteEV = False
        End Try

        If boolWriteEV Then
            '
            ' Log Source
            '
            Dim rstrLogName As String
            Try
                rstrLogName = CType(oAppSettings("EventLog.Application"), String)
            Catch ex As Exception
                rstrLogName = "Application"
            End Try
            '
            ' Aggiungo info utente
            '
            'DescOperation = "Utente: " & HttpContext.Current.User.Identity.Name & vbCrLf & _
            '            DescOperation
            Dim sUtente As String = String.Empty
            Try
                sUtente = "Utente: " & HttpContext.Current.User.Identity.Name & vbCrLf
            Catch ex As Exception
            End Try
            DescOperation = sUtente & DescOperation
            '
            ' Scrivo errore
            '
            EventLog.WriteEntry(rstrLogName, DescOperation, EventLogEntryType.Warning)
        End If

    End Sub

    Public Shared Sub WriteError(ByVal ExError As Exception, ByVal DescOperation As String)
        '
        ' Scrive l'errore passato
        '
        Dim oAppSettings As Specialized.NameValueCollection = ConfigurationManager.AppSettings

        Dim boolWriteEV As Boolean
        Try
            boolWriteEV = CType(oAppSettings("EventLog.Error"), Boolean)
        Catch ex As Exception
            boolWriteEV = False
        End Try

        If boolWriteEV Then
            '
            ' Log Source
            '
            Dim rstrLogName As String
            Try
                rstrLogName = CType(oAppSettings("EventLog.Application"), String)
            Catch ex As Exception
                rstrLogName = "Application"
            End Try
            '
            ' Message
            '
            Dim strMessage As String
            If Not ExError Is Nothing Then
                '
                ' Compongo il messaggio di errore 
                '
                strMessage = GetMessageError(ExError, DescOperation)
            Else
                strMessage = DescOperation
            End If
            '
            ' Aggiungo info utente
            '
            Dim sUtente As String = String.Empty
            Try
                sUtente = "Utente: " & HttpContext.Current.User.Identity.Name & vbCrLf
            Catch ex As Exception
            End Try
            strMessage = sUtente & strMessage
            '
            ' Scrivo errore
            '
            EventLog.WriteEntry(rstrLogName, strMessage, EventLogEntryType.Error)

            '
            'Gestisco l'errore su application insights
            '
            Dim dicProp As New Dictionary(Of String, String)
            dicProp.Add("Portale", "DWH User Bootstrap")
            dicProp.Add("Descrizione Operazione", DescOperation)
            Dim ai = New TelemetryClient()
            ai.TrackException(ExError, dicProp)
        End If
    End Sub

    Public Shared Function GetMessageError(ByVal robjError As Exception,
                                 ByVal rstrDescOperation As String) As String
        '
        ' Ritorna il messaggio di errore
        '

        '
        ' Nuovo oggetto StackTrace
        '
        Dim objStackTrace As New StackTrace(True)
        '
        ' Prendo 2 frame precedenti (il precedente è la funzione WriteError)
        '
        Dim objStackFrame As StackFrame = objStackTrace.GetFrame(2)
        Dim objMemberInfo As System.Reflection.MemberInfo = objStackFrame.GetMethod

        Dim strMessage As String = "Errore: " & robjError.Message.ToString & ControlChars.CrLf &
                                   "Sorgente: " & robjError.Source & ControlChars.CrLf &
                                   "Modulo: " & objMemberInfo.ReflectedType.FullName &
                                   "." & objMemberInfo.Name & ControlChars.CrLf &
                                   rstrDescOperation
        If TypeOf (robjError) Is System.Net.Sockets.SocketException Then
            '
            ' SocketException; aggiungo errore nativo
            '
            Dim objErr As System.Net.Sockets.SocketException = CType(robjError, System.Net.Sockets.SocketException)

            strMessage &= "Codice errore nativo: " & objErr.NativeErrorCode.ToString() & ControlChars.CrLf
        End If
        '
        ' Aggiungo Stack Trace
        '
        strMessage &= "Stack Trace:" & robjError.StackTrace & ControlChars.CrLf
        '
        ' Ritorno valore
        '
        Return strMessage

    End Function

End Class

