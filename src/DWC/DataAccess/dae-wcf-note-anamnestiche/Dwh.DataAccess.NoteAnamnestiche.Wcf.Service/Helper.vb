Imports System.Data

Public Class Helper

    '''' <summary>
    '''' Tenta più volte di aprire la connessione al DB
    '''' </summary>
    'Public Shared Sub CheckConnectionString(ConnectionString As String)
    '	'
    '	' Test di apertura connessione al DB
    '	'
    '	For iRetry As Integer = 0 To My.Settings.RetryCount
    '		Try
    '               If iRetry > 0 Then
    '                   '
    '                   ' Log dal secondo tentativo in poi
    '                   '
    '                   Log.TraceWriteLine(String.Format("Riprova numero {0} CheckConnectionString!", iRetry), TraceLevel.Info.ToString, TraceLevel.Info.ToString)
    '               End If

    '               Dim sResult As String = Helper.ConnectionTest(ConnectionString)
    '			Log.TraceWriteLine("CheckConnectionString Esito=" & sResult, TraceLevel.Info.ToString, TraceLevel.Info.ToString)
    '			'
    '			' Se processato esce dal loop
    '			'
    '			Exit For

    '		Catch ex As Exception
    '			'
    '			' Errore su ConnectionTest
    '			'
    '			Log.WriteError(ex, "Errore durante CheckConnectionString")
    '			If iRetry = My.Settings.RetryCount Then
    '				'
    '				' Raggiunto il numero massimo di tentativi: Throw di una CustomException
    '				'
    '				Throw New CustomException(String.Format("Raggiunto il numero massimo ({0}) di tentativi di apertura della connessione: {1}", My.Settings.RetryCount, ConnectionString), ErrorCodes.NetError)
    '			Else
    '                   '
    '                   ' Attesa
    '                   '
    '                   If My.Settings.WaitAfterNetError > 0 Then
    '                       'Log.TraceWriteLine(String.Format("Errore di connessione. Attesa di {0} ms. Il processamento continua.", My.Settings.WaitAfterNetError), TraceLevel.Info.ToString, TraceLevel.Info.ToString)
    '                       Threading.Thread.Sleep(My.Settings.WaitAfterNetError)
    '                   End If
    '               End If
    '		End Try
    '	Next

    'End Sub


    '''' <summary>
    '''' Verifica la connessione al DB, non gestisce eccezioni
    '''' </summary>
    'Private Shared Function ConnectionTest(ConnectionString As String) As String
    '   Dim sRet As String = String.Empty
    '	Using oSqlConn As SqlClient.SqlConnection = New SqlClient.SqlConnection(ConnectionString)
    '		oSqlConn.Open()
    '		sRet = "ServerVersion=" & oSqlConn.ServerVersion
    '		oSqlConn.Close()
    '		oSqlConn.Dispose()
    '	End Using

    '	Return sRet

    'End Function


End Class
