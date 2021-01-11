Imports System.Text
Imports System.Diagnostics
Imports System.Xml

Friend Class Log

    Private Const TRACE_NAME_DAE As String = "DAE-NoteAnamnestiche " ' con lo spazio finale

    Public Shared Sub TraceWriteLine(ByVal Message As String, ByVal Category As String, ByVal Severity As String)
        If My.Settings.LogTrace Then
            Message = String.Concat(TRACE_NAME_DAE, Message)
            Trace.WriteLine(String.Format("{0} {1:HH:mm:ss.fff} - {2}", Severity, DateTime.Now, Message), Category)
        End If
    End Sub

    Public Shared Sub TraceWrite(ByVal Message As String, ByVal Category As String, ByVal Severity As String)
        If My.Settings.LogTrace Then
            Message = String.Concat(TRACE_NAME_DAE, Message)
            Trace.Write(String.Format("{0} {1:HH:mm:ss.fff} - {2}", Severity, DateTime.Now, Message), Category)
        End If
    End Sub


    Public Shared Sub WriteInformation(ByVal Message As String)

        Try
            Dim sSource As String = My.Settings.LogSource
            '
            ' Controllo se abilitato
            '
            If My.Settings.LogInformation AndAlso Not String.IsNullOrEmpty(sSource) Then
                EventLog.WriteEntry(sSource, Message, EventLogEntryType.Information)
            End If
            '
            ' Trace DBView
            '
            Log.TraceWrite(Message, sSource, "Info")

        Catch ex As Exception
        End Try

    End Sub

    Public Shared Sub WriteWarning(ByVal Message As String)

        Try
            Dim sSource As String = My.Settings.LogSource
            '
            ' Controllo se abilitato
            '
            If (My.Settings.LogWarning AndAlso Not String.IsNullOrEmpty(sSource)) Then
                EventLog.WriteEntry(sSource, Message, EventLogEntryType.Warning)
            End If
            '
            ' Trace DBView
            '
            Log.TraceWrite(Message, sSource, "Warning")

        Catch ex As Exception
        End Try

    End Sub

    Public Shared Sub WriteError(ByVal ErrorException As Exception)
        WriteError(ErrorException, Nothing)
    End Sub

    Public Shared Sub WriteError(ByVal ErrorException As Exception, ByVal Message As String)

        Try
            Dim sSource As String = My.Settings.LogSource
            '
            ' Controllo se abilitato
            '
            If My.Settings.LogError AndAlso Not String.IsNullOrEmpty(sSource) Then
                Dim sbMessage As New Text.StringBuilder

                If Not String.IsNullOrEmpty(Message) Then
                    sbMessage.AppendLine(Message)
                    sbMessage.AppendLine()
                End If
                '
                ' Appende dettaglio della EX
                '
                If Not ErrorException Is Nothing Then
                    GetExceptionToStringBuilder(ErrorException, sbMessage)
                End If

                EventLog.WriteEntry(sSource, sbMessage.ToString, EventLogEntryType.Error)
            End If
            '
            ' Trace DBView
            '

            If My.Settings.LogTrace Then

                Dim sbMessage As New Text.StringBuilder

                If Not String.IsNullOrEmpty(Message) Then
                    sbMessage.Append(Message)
                    sbMessage.Append(" - ")
                End If
                '
                ' Appende solo errore della EX
                '
                If Not ErrorException Is Nothing Then
                    GetErrorToStringBuilder(ErrorException, sbMessage)
                End If

                Log.TraceWrite(sbMessage.ToString, sSource, "Error")
            End If

        Catch ex As Exception
        End Try

    End Sub

    Public Shared Function GetExceptionToStringBuilder(ByVal ErrorException As Exception, MessageStringBuilder As Text.StringBuilder) As Text.StringBuilder

        MessageStringBuilder.AppendLine("Exception info ***************")
        MessageStringBuilder.AppendLine()

        Return GetExceptionToStringBuilder(ErrorException, MessageStringBuilder, 0)

    End Function

    Public Shared Function GetExceptionToStringBuilder(ByVal ErrorException As Exception, MessageStringBuilder As Text.StringBuilder, Level As Integer) As Text.StringBuilder
        '
        ' Legge tutti i dettagli della eccezzione
        '
        If Not ErrorException Is Nothing Then
            MessageStringBuilder.AppendLine(ErrorException.Message)
            MessageStringBuilder.AppendLine()

            MessageStringBuilder.AppendFormat("Source = {0}", ErrorException.Source)
            MessageStringBuilder.AppendLine()

            MessageStringBuilder.AppendFormat("StackTrace = {0}", ErrorException.StackTrace)
            MessageStringBuilder.AppendLine()
        End If
        '
        ' Se inner e non più di 10 chiama recursiva
        '
        If Not ErrorException.InnerException Is Nothing AndAlso Level < 10 Then
            Level += 1

            MessageStringBuilder.AppendFormat("InnerException livello={0} ***************", Level)
            MessageStringBuilder.AppendLine()

            GetExceptionToStringBuilder(ErrorException.InnerException, MessageStringBuilder, Level)
        End If

        Return MessageStringBuilder

    End Function

    Public Shared Function GetErrorToStringBuilder(ByVal ErrorException As Exception, MessageStringBuilder As Text.StringBuilder) As Text.StringBuilder

        Return GetErrorToStringBuilder(ErrorException, MessageStringBuilder, 0)

    End Function

    Public Shared Function GetErrorToStringBuilder(ByVal ErrorException As Exception, MessageStringBuilder As Text.StringBuilder, Level As Integer) As Text.StringBuilder
        '
        ' Legge solo il messaggio di errore
        '
        If Not ErrorException Is Nothing Then
            If Level > 0 Then
                MessageStringBuilder.AppendFormat(" "c, Level)
            End If

            MessageStringBuilder.AppendLine(ErrorException.Message)
        End If
        '
        ' Se inner e non più di 5 chiama recursiva
        '
        If Not ErrorException.InnerException Is Nothing AndAlso Level < 6 Then
            Level += 1
            GetExceptionToStringBuilder(ErrorException.InnerException, MessageStringBuilder, Level)
        End If

        Return MessageStringBuilder

    End Function

End Class

