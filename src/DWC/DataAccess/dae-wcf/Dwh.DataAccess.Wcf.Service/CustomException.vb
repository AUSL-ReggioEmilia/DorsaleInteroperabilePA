''' <summary>
''' Codici di errore censiti
''' </summary>
Public Enum ErrorCodes
	MetodoNonImplementato
	ErroreGenerico
	ParametroMancante
	'ErroreDiConversione
	NetError
	Deadlocked
	Timeout
	ErroreSAC
	ErroreDWH
	DatoNonTrovato
	OperazioneNonEseguita
	ErroreAttributiAnagrafici
	ErroreAttributiXML
	ParsingAllegato
End Enum


''' <summary>
''' Exception che conserva anche un codice di errore
''' </summary>
Public Class CustomException
	Inherits Exception

	Public ErrorCode As String

	Public Sub New()
	End Sub

	Public Sub New(ByVal Message As String, ByVal ErrorCode As String)
		MyBase.New(Message)

		Me.ErrorCode = ErrorCode
	End Sub

	Public Sub New(ByVal Message As String, ByVal ErrorCode As ErrorCodes, Optional WriteEventLog As Boolean = False)
		MyBase.New(Message)

		Me.ErrorCode = ErrorCode.ToString

		'se richiesto loggo l'errore
		If WriteEventLog Then
			Log.WriteError(Me)
		End If
	End Sub

End Class
