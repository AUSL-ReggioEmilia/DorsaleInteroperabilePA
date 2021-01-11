'--------------------------------------------------------------------------
' In base al valore dei codici/numero di errore l'orchestrazione verra SOSPESA o TERMINATA
' Se l'orchestrazione riceve un codice/numero di errore >= 1000 l'orchestrazione viene SOSPESA
' Se l'orchestrazione riceve un codice/numero di errore  < 1000 l'orchestrazione viene TERMINATA
'--------------------------------------------------------------------------
''' <summary>
''' Codici di errore censiti
''' </summary>
Public Enum ErrorCodes
    '-----------------------------------------------------
    ' Errori con cui l'orchestrazione termina
    '-----------------------------------------------------
    MetodoNonImplementato = 0   'L'orchestrazione termina

    '-----------------------------------------------------
    ' Errori con cui l'orchestrazione viene sospesa
    '-----------------------------------------------------
    NetError = 1000 'Sospensione (dopo cicli di retry della DAE) cosi si può resumare la orchestrazione
    Deadlocked = 1010 'Sospensione (dopo cicli di retry della DAE) cosi si può resumare la orchestrazione
    Timeout = 1020 'Sospensione (dopo cicli di retry della DAE) cosi si può resumare la orchestrazione
    ErroreGenerico = 1030 'Sospensione per averne evidenza
    ParametroMancante = 1040 'Sospensione per averne evidenza 
    ErroreSAC = 1050 'Sospensione per averne evidenza 
    ErroreAttributiAnagrafici = 1060 'Sospensione per avere evidenza di un errore durante la costruzione dei dati anagrafici
    ErroreBuildingOutput = 1070 'Sospensione per avere evidenza: errore durante la costruzione dell'oggetto restituito dalla DAE
    ParametroNonValido = 1080
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
