Imports System.Diagnostics
Imports System.Configuration

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
            ' Scrivo errore
            '
            EventLog.WriteEntry(rstrLogName, DescOperation, EventLogEntryType.Warning)
        End If

    End Sub

    Public Shared Sub WriteError(ByVal ExError As Exception, ByVal DescOperation As String)
        '
        ' MODIFICA ETTORE 2017-09-20: non scrivo l'errore ThreadAbortException
        '
        If TypeOf ExError Is Threading.ThreadAbortException Then
            Return
        End If
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
                ' Compongo il messaggio di errore il messaggio di errore
                '
                strMessage = GetMessageError(ExError, DescOperation)
            Else
                strMessage = DescOperation
            End If
            '
            ' Scrivo errore
            '
            EventLog.WriteEntry(rstrLogName, strMessage, EventLogEntryType.Error)
        End If

    End Sub

    Public Shared Function GetMessageError(ByVal robjError As Exception, _
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

        Dim strMessage As String = "Errore: " & robjError.Message.ToString & ControlChars.CrLf & _
                                                    "Sorgente: " & robjError.Source & ControlChars.CrLf & _
                                                    "Modulo: " & objMemberInfo.ReflectedType.FullName & _
                                                        "." & objMemberInfo.Name & ControlChars.CrLf & _
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
