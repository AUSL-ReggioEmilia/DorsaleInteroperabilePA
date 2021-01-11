''' <summary>
''' Classe che rappresenta l'utente correntemente loggato
''' </summary>
Public Class Utente

	Public Property AccountName As String
	Public Property UserName As String
	Public Property Id As Guid?
	Public Property Dominio As String
	Public Property Email As String
	Public Property Nome As String
	Public Property Cognome As String
	Public Property CodiceFiscale As String

End Class

''' <summary>
''' Caricamento dei dati dell'utente correntemente loggato
''' </summary>
Public Class GestioneUtente

	Public Shared Function GetUtenteCorrente() As Utente
		Dim oUtente As Utente
		Try
			oUtente = MySession.DettaglioUtente
			If oUtente Is Nothing Then
				oUtente = New Utente
				'
				' DATI RICAVATI DALL'UTENTE LOGGATO
				'
				oUtente.AccountName = HttpContext.Current.User.Identity.Name
				Dim iSep As Integer = oUtente.AccountName.IndexOf("\")
				If iSep = -1 Then Throw New ApplicationException("Utente " & oUtente.AccountName & " non valido.")
				oUtente.UserName = oUtente.AccountName.Substring(iSep + 1)
				oUtente.Dominio = oUtente.AccountName.Substring(0, iSep)
				'
				' QUERY SU SAC
				'
				Using ta As New SACDatasetTableAdapters.UtentiTableAdapter
					Dim dt = ta.GetData(oUtente.AccountName)
					If dt Is Nothing OrElse dt.Count = 0 Then
						Throw New ApplicationException("L'utente " & oUtente.AccountName & " non è stato trovato su database SAC. Contattare un amministratore")
					End If
					Dim dr = dt(0)
					oUtente.Id = dr.Id
					If Not dr.IsNomeNull Then oUtente.Nome = dr.Nome
					If Not dr.IsCognomeNull Then oUtente.Cognome = dr.Cognome
					If Not dr.IsEmailNull Then oUtente.Email = dr.Email
					If Not dr.IsCodiceFiscaleNull Then oUtente.CodiceFiscale = dr.CodiceFiscale
					' LO SALVO IN SESSION PER OTTIMIZZARE
					MySession.DettaglioUtente = oUtente
				End Using
			End If

			Return oUtente

		Catch ex As Exception
			GestioneErrori.WriteException("Errore durante GetDettaglioUtente({0}); Messaggio: {1}", HttpContext.Current.User.Identity.Name, ex.Message)
			Throw ex
		End Try
	End Function

End Class
