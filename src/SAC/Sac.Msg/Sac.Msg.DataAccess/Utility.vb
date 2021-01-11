Imports System.Xml
Imports System.Text
Imports System.Collections.Specialized
Imports System.Diagnostics
Imports System.Globalization
Imports Microsoft.Win32
Imports System.Threading

Public Class LogEvent

    Public Shared Sub WriteError(ByVal sMessage As String)

        Try
            Dim bEnabled As Boolean = ConfigSingleton.LogError
            '
            ' Controllo se abilitato
            '
            If bEnabled Then
                EventLog.WriteEntry(ConfigSingleton.LogSource, sMessage, EventLogEntryType.Error)
            End If

        Catch ex As Exception
        End Try

    End Sub

    Public Shared Sub WriteError(ByVal Exception As Exception, ByVal sMessage As String)

        Try
            Dim bEnabled As Boolean = ConfigSingleton.LogError
            '
            ' Controllo se abilitato
            '
            If bEnabled Then
                If sMessage IsNot Nothing AndAlso sMessage.Length > 0 Then
                    sMessage &= vbCrLf
                End If
                EventLog.WriteEntry(ConfigSingleton.LogSource, FormatException(Exception, sMessage), EventLogEntryType.Error)
            End If

        Catch ex As Exception
        End Try

    End Sub

    Public Shared Sub WriteWarning(ByVal sMessage As String)

        Try
            Dim bEnabled As Boolean = ConfigSingleton.LogWarning
            '
            ' Controllo se abilitato
            '
            If bEnabled Then
                EventLog.WriteEntry(ConfigSingleton.LogSource, sMessage, EventLogEntryType.Warning)
            End If

        Catch ex As Exception
        End Try

    End Sub

    Public Shared Sub WriteInformation(ByVal sMessage As String)

        Try
            Dim bEnabled As Boolean = ConfigSingleton.LogInformation
            '
            ' Controllo se abilitato
            '
            If bEnabled Then
                EventLog.WriteEntry(ConfigSingleton.LogSource, sMessage, EventLogEntryType.Information)
            End If

        Catch ex As Exception
        End Try

    End Sub

    ''' <summary>
    ''' Formatta l'eccezione eseguendo un cilo sulle inner exception. Aggiunge il nome dell'utente loggato
    ''' </summary>
    ''' <param name="Exception"></param>
    ''' <param name="AdditionalInfo"></param>
    ''' <returns></returns>
    Public Shared Function FormatException(ByVal Exception As Exception, ByVal AdditionalInfo As String) As String
        '
        ' Controllo che Exception non sia nothing
        '
        If Exception Is Nothing Then
            'Forse qui si potrebbe restituire stringa vuota
            Throw New ArgumentNullException("exception")
        End If
        '
        ' Creo textBuilder e aggiungo informazioni addizionali
        '
        Dim result As New System.Text.StringBuilder()
        If Not String.IsNullOrEmpty(AdditionalInfo) Then
            result.AppendLine(AdditionalInfo)
        End If
        '
        ' Scrivo l'eccezione e loop sulle inner exception
        '
        Dim currentException As Exception = Exception
        While Exception IsNot Nothing
            result.AppendLine(Exception.Message)
            result.AppendLine(Exception.StackTrace)
            Exception = Exception.InnerException
        End While
        '
        ' Restituisco il messaggio completo
        '
        Return result.ToString()
    End Function
End Class

Friend Class XmlUtil

    Public Shared Function FormatDatetime(ByVal DataOra As Date) As String
        '
        ' Ritorna DbNull se data minima
        '
        Try
            If DataOra = #1/1/1753# Then
                Return ""
            Else
                Return DataOra.ToString("s")
            End If

        Catch ex As Exception
            Return ""
        End Try

    End Function

    Public Shared Function ParseDatetime(ByVal DataOraString As String) As Date
        '
        ' Ritorna data minima se vuoto
        '
        Try
            If Not DataOraString Is Nothing AndAlso DataOraString.Length > 0 Then
                Dim culture As CultureInfo = New CultureInfo("en-US", True)
                Return Date.Parse(DataOraString, culture)
            Else
                Return #1/1/1753#
            End If

        Catch ex As Exception
            Return #1/1/1753#
        End Try

    End Function

End Class

Friend Class SqlUtil

    Public Shared Function ParseDatetime(ByVal DataOra As Date) As Object
        '
        ' Ritorna DbNull se data minima
        '
        Try
            If DataOra = #1/1/1753# Then
                Return DBNull.Value
            Else
                Return DataOra
            End If

        Catch ex As Exception
            Return DBNull.Value
        End Try

    End Function

    Public Shared Function StringNothingToDbNull(ByVal Value As String) As Object
        '
        ' Ritorna DbNull se data minima
        '
        Try
            If Value Is Nothing Then
                Return DBNull.Value
            Else
                Return Value
            End If

        Catch ex As Exception
            Return DBNull.Value
        End Try

    End Function

    Public Shared Function StringEmptyToDbNull(ByVal Value As String) As Object
        '
        ' Ritorna DbNull se data minima
        '
        Try
            If Value Is Nothing OrElse Value.Trim.Length = 0 Then
                Return DBNull.Value
            Else
                Return Value
            End If

        Catch ex As Exception
            Return DBNull.Value
        End Try

    End Function

End Class

Friend Class Util

    Public Const DateFormat As String = "yyyy'-'MM'-'dd"

    Public Shared Function FormatDate(ByVal [date] As String, ByVal param As String) As Nullable(Of DateTime)
        Try
            Return Date.ParseExact([date], DateFormat, Nothing)
        Catch ex As Exception
            Throw New FormatException(String.Concat("Il valore del parametro ", param, _
                                                    " non è nel formato corretto (", DateFormat.Replace("'", ""), ")."))
        End Try
    End Function

End Class