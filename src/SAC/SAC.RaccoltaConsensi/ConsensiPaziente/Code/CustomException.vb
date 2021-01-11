''' <summary>
''' Codici di errore censiti
''' </summary>
Public Enum ErrorCodes
	ErroreGenerico
	ParametroMancante
	PazienteNonTrovato
	ErroreSAC

End Enum

''' <summary>
''' Exception che conserva anche un codice di errore
''' </summary>
Public Class CustomException
	Inherits Exception

	Public ErrorCode As ErrorCodes = ErrorCodes.ErroreGenerico

	Public Sub New()
		MyBase.New()
	End Sub

	Public Sub New(ByVal Message As String, ByVal ErrorCode As ErrorCodes)

		MyBase.New(Message)
		Me.ErrorCode = ErrorCode

	End Sub

End Class
