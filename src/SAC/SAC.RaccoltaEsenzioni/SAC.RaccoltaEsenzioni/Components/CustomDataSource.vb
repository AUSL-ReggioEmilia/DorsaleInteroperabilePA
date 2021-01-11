Imports System.ComponentModel
Imports System.Linq

<DataObject(True)>
Public Class CustomDataSource

	Private Const _MaxNumRecord As Integer = 100

	''' <summary>
	''' Metodo di creazione delle credenziali di accesso al wcf.
	''' </summary>
	''' <param name="oWs"></param>
	Private Sub SetCredentials(ByVal oWs As WcfSacPazienti.PazientiClient)
		'autenticazione in BASIC con utente e password lette da file di configurazione
		Utility.SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, My.Settings.WcfSac_User, My.Settings.WcfSac_Password)
	End Sub

	''' <summary>
	''' Metodo di creazione delle credenziali di accesso al wcf.
	''' </summary>
	''' <param name="oWs"></param>
	Private Sub SetCredentials(ByVal oWs As WcfSacDizionari.DizionariClient)
		'autenticazione in BASIC con utente e password lette da file di configurazione
		Utility.SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, My.Settings.WcfSac_User, My.Settings.WcfSac_Password)
	End Sub

	''' <summary>
	''' Metodo di creazione delle credenziali di accesso al wcf.
	''' </summary>
	''' <param name="oWs"></param>
	Private Sub SetCredentials(ByVal oWs As WcfSacRoleManager.RoleManagerClient)
		'autenticazione in BASIC con utente e password lette da file di configurazione
		Utility.SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, My.Settings.WcfSac_User, My.Settings.WcfSac_Password)
	End Sub

	''' <summary>
	''' Metodo di ricerda dei pazienti.
	''' </summary>
	''' <param name="Token"></param>
	''' <param name="Cognome"></param>
	''' <param name="Nome"></param>
	''' <param name="AnnoNascita"></param>
	''' <param name="CodiceFiscale"></param>
	''' <returns></returns>
	Public Function PazientiCerca(Token As WcfSacPazienti.TokenType, Cognome As String, Nome As String, AnnoNascita As Integer?, CodiceFiscale As String) As WcfSacPazienti.PazientiListaType
		'Dichiaro l'oggetto da restituire.
		Dim pazientiListaType As WcfSacPazienti.PazientiListaType

		Using Wcf As New WcfSacPazienti.PazientiClient

			'Setto le credenziali per connettermi al SAC.
			SetCredentials(Wcf)

			'Ottengo i dati
			Dim pazientiReturn As WcfSacPazienti.PazientiReturn = Wcf.PazientiCerca(Token, _MaxNumRecord, Nothing, Cognome, Nome, Nothing, AnnoNascita, Nothing, CodiceFiscale, Nothing)

			'Testo se oReturn non è vuoto.
			If pazientiReturn IsNot Nothing Then

				'Se il nodo Errore non è vuoto allora eseguo il throw di una custom exception.
				If pazientiReturn.Errore IsNot Nothing Then
					Throw New CustomDataSourceException("Si è verificato un errore durante la lettura della lista pazienti.", pazientiReturn.Errore.Codice, pazientiReturn.Errore.Descrizione)
				Else
					'Ottengo il nodo Pazienti
					pazientiListaType = pazientiReturn.Pazienti
				End If
			End If
		End Using

		'Restituisco l'oggetto.
		Return pazientiListaType
	End Function

	''' <summary>
	''' Metodo che restituisce un paziente in base al suo id
	''' </summary>
	''' <param name="Token"></param>
	''' <param name="Id"></param>
	''' <returns></returns>
	Public Function PazientiOttieniPerId(Token As WcfSacPazienti.TokenType, Id As Guid) As WcfSacPazienti.PazienteType
		'Dichiaro l'oggetto da restituire.
		Dim pazienteType As WcfSacPazienti.PazienteType

		Using Wcf As New WcfSacPazienti.PazientiClient

			'Setto le credenziali per connettermi al SAC.
			SetCredentials(Wcf)

			'Ottengo i dati
			Dim pazienteReturn As WcfSacPazienti.PazienteReturn = Wcf.PazienteOttieniPerId(Token, Id)

			'Testo se oReturn non è vuoto.
			If pazienteReturn IsNot Nothing Then

				'Se il nodo Errore non è vuoto allora eseguo il throw di una custom exception.
				If pazienteReturn.Errore IsNot Nothing Then
					Throw New CustomDataSourceException("Si è verificato un errore durante la lettura del paziente.", pazienteReturn.Errore.Codice, pazienteReturn.Errore.Descrizione)
				Else
					'Ottengo il nodo Paziente
					pazienteType = pazienteReturn.Paziente
				End If
			End If
		End Using

		'Restituisco l'oggetto.
		Return pazienteType
	End Function


	''' <summary>
	''' Metodo che restituisce la lista delle esenzioni di un paziente
	''' </summary>
	''' <param name="Token"></param>
	''' <param name="Id"></param>
	''' <returns></returns>
	Public Function EsenzioniOttieniPerIdPaziente(Token As WcfSacPazienti.TokenType, Id As Guid) As WcfSacPazienti.EsenzioniType
		'Dichiaro l'oggetto da restituire.
		Dim esenzioniType As WcfSacPazienti.EsenzioniType

		Using Wcf As New WcfSacPazienti.PazientiClient
			'Setto le credenziali per connettermi al SAC.
			SetCredentials(Wcf)

			'Ottengo i dati
			Dim pazienteType As WcfSacPazienti.PazienteType = PazientiOttieniPerId(Token, Id)

			'Testo se oReturn non è vuoto.
			If pazienteType IsNot Nothing Then
				'Se il nodo Errore non è vuoto allora eseguo il throw di una custom exception.
				esenzioniType = pazienteType.Esenzioni
			End If
		End Using

		'Restituisco l'oggetto.
		Return esenzioniType
	End Function

	Public Function EsenzioneOttieniPerCodice(Token As WcfSacDizionari.TokenType, Codice As String, Descrizione As String) As WcfSacDizionari.EsenzioniListaType

		'Dichiaro l'oggetto da restituire.
		Dim esenzione As WcfSacDizionari.EsenzioniListaType

		Using Wcf As New WcfSacDizionari.DizionariClient
			'Setto le credenziali per connettermi al SAC.
			SetCredentials(Wcf)

			If (Not (String.IsNullOrWhiteSpace(Codice) AndAlso String.IsNullOrWhiteSpace(Descrizione))) Then
				'Ottengo i dati
				Dim esenzioneReturn As WcfSacDizionari.EsenzioniReturn = Wcf.DizionariEsenzioniCerca(Token, 1000, Nothing, Codice, Descrizione)

				'Testo se oReturn non è vuoto.
				If esenzioneReturn IsNot Nothing Then
					'Se il nodo Errore non è vuoto allora eseguo il throw di una custom exception.
					esenzione = esenzioneReturn.Esenzioni
				End If
			End If
		End Using

		'Restituisco l'oggetto.
		Return esenzione
	End Function

	''' <summary>
	'''  Funzione che si occupa dell'inserimento di una nuova esenzione
	''' </summary>
	''' <param name="Token"></param>
	''' <param name="CodiceEsenzione"></param>
	''' <param name="CodiceDiagnosi"></param>
	''' <param name="Patologica"></param>
	''' <param name="DataInizioValidita"></param>
	''' <param name="DataFineValidita"></param>
	''' <param name="NumeroAutorizzazioneEsenzione"></param>
	''' <param name="NoteAggiuntive"></param>
	''' <param name="CodiceDescrizioneEsenzione"></param>
	''' <param name="DescrizioneEsenzione"></param>
	''' <param name="DecodificaEsenzioneDiagnosi"></param>
	''' <param name="AttributoEsenzioneDiagnosi"></param>
	''' <param name="IdPaziente"></param>
	''' <returns></returns>
	Public Function EsenzioniAggiungi(Token As WcfSacPazienti.TokenType, CodiceEsenzione As String, CodiceDiagnosi As String, Patologica As Boolean,
									   DataInizioValidita As DateTime, DataFineValidita As DateTime?, NumeroAutorizzazioneEsenzione As String,
									   NoteAggiuntive As String, CodiceDescrizioneEsenzione As String, DescrizioneEsenzione As String,
									   DecodificaEsenzioneDiagnosi As String, AttributoEsenzioneDiagnosi As String,
									   IdPaziente As Guid) As WcfSacPazienti.EsenzioneType

		'Definisco l'oggetto da restituire
		Dim esenzioneType As WcfSacPazienti.EsenzioneType

		'creo codiceDescrizioneType
		Dim codiceDescrizioneType = New WcfSacPazienti.CodiceDescrizioneType() With {.Codice = CodiceDescrizioneEsenzione, .Descrizione = DescrizioneEsenzione}

		Dim utente As WcfSacRoleManager.UtenteType = UtenteOttieniPerNomeUtente(HttpContext.Current.User.Identity.Name)

		'creo operatoreParam
		Dim operatoreParam = New WcfSacPazienti.OperatoreType With {.Cognome = utente.Cognome, .Nome = utente.Nome, .Id = utente.Utente, .Computer = HttpContext.Current.Request.ServerVariables("REMOTE_HOST")}

		'creo un nuovo EsenzioneDettagliType
		Dim esenzioneDettagliType As New WcfSacPazienti.EsenzioneType With {
						.CodiceEsenzione = CodiceEsenzione,
						.CodiceDiagnosi = CodiceDiagnosi,
						.Patologica = Patologica,
						.DataInizioValidita = DataInizioValidita,
						.DataFineValidita = DataFineValidita,
						.NumeroAutorizzazioneEsenzione = NumeroAutorizzazioneEsenzione,
						.NoteAggiuntive = NoteAggiuntive,
						.TestoEsenzione = codiceDescrizioneType,
						.DecodificaEsenzioneDiagnosi = DecodificaEsenzioneDiagnosi,
						.AttributoEsenzioneDiagnosi = AttributoEsenzioneDiagnosi,
						.Operatore = operatoreParam
						}


		Using Wcf As New WcfSacPazienti.PazientiClient
			'Setto le credenziali per connettermi al SAC.
			SetCredentials(Wcf)

			'Ottengo i dati
			Dim esenzioneReturn As WcfSacPazienti.EsenzioneReturn = Wcf.EsenzioneAggiungi(Token, esenzioneDettagliType, IdPaziente)

			'Se il nodo Errore non è vuoto allora eseguo il throw di una custom exception.
			If esenzioneReturn.Errore IsNot Nothing Then
				Throw New CustomDataSourceException("Si è verificato un errore durante  l'inserimento dell'esenzione.", esenzioneReturn.Errore.Codice, esenzioneReturn.Errore.Descrizione)
			Else
				'Ottengo il nodo Esenzione
				esenzioneType = esenzioneReturn.Esenzione
			End If
		End Using

		'Restituisco l'oggetto.
		Return esenzioneType
	End Function


	''' <summary>
	''' Funzione che si occupa dell'eliminazione delle esenzioni
	''' </summary>
	''' <param name="Token"></param>
	''' <param name="IdEsenzione"></param>
	Public Sub EsenzioneEliminaPerIdEsenzione(Token As WcfSacPazienti.TokenType, IdEsenzione As Guid)

		Using Wcf As New WcfSacPazienti.PazientiClient
			'Setto le credenziali per connettermi al SAC.
			SetCredentials(Wcf)

			'elimino l'esenzione
			Dim erroreReturn As WcfSacPazienti.ErroreReturn = Wcf.EsenzioneEliminaPerIdEsenzione(Token, IdEsenzione)

			'Se erroreReturn non è vuoto allora eseguo il throw di una custom exception.
			If erroreReturn IsNot Nothing AndAlso erroreReturn.Errore IsNot Nothing Then
				Throw New CustomDataSourceException("Si è verificato un errore durante la cancellazione dell'esenzione.", erroreReturn.Errore.Codice, erroreReturn.Errore.Descrizione)
			End If
		End Using
	End Sub


	Public Function UtenteOttieniPerNomeUtente(NomeUtente As String) As WcfSacRoleManager.UtenteType
		Dim utenteType As WcfSacRoleManager.UtenteType

		Using Wcf As New WcfSacRoleManager.RoleManagerClient
			'Setto le credenziali per connettermi al SAC.
			SetCredentials(Wcf)

			'Ottengo i dati
			Dim utenteReturn As WcfSacRoleManager.UtenteReturn = Wcf.UtenteOttieniPerNomeUtente(NomeUtente)

			'Se il nodo Errore non è vuoto allora eseguo il throw di una custom exception.
			If utenteReturn.Errore IsNot Nothing Then
				Throw New CustomDataSourceException("Si è verificato un errore durante la ricerca dell'utente corrente.", utenteReturn.Errore.Codice, utenteReturn.Errore.Descrizione)
			Else
				'Ottengo il nodo Esenzione
				utenteType = utenteReturn.Utente
			End If
		End Using

		Return utenteType
	End Function

End Class



