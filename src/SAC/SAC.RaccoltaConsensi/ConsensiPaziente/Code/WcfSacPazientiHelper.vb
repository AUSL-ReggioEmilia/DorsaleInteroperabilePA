Imports Wcf.SacPazienti	'tipi esposti dal webservice SacPazienti
Imports System.ComponentModel

<DataObject(True)>
Public Class WcfSacPazientiHelper

	Private Sub SetCredentials(ByVal oWs As PazientiSoapClient)

		'autenticazione in BASIC con utente e password lette da file di configurazione
		ServiceHelper.SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, My.Settings.SACUsername, My.Settings.SACPassword)

	End Sub

	''' <summary>
	''' Ricerca pazienti su SAC
	''' </summary>
	Public Function PazientiCerca(Cognome As String, Nome As String, AnnoNascita As String, CodiceFiscale As String) As Wcf.SacPazienti.PazientiCerca3ResponsePazientiCerca2()

		Dim sMsg As String = ""
		If Not String.IsNullOrEmpty(Cognome) Then sMsg += "Cognome: " & Cognome
		If Not String.IsNullOrEmpty(Nome) Then sMsg += ", Nome: " & Nome
		If Not String.IsNullOrEmpty(AnnoNascita) Then sMsg += ", Anno Nascita: " & AnnoNascita
		If Not String.IsNullOrEmpty(CodiceFiscale) Then sMsg += ", Codice Fiscale: " & CodiceFiscale
		Try

			Using ws As New PazientiSoapClient
				'
				'Setto le credenziali per connettermi al SAC
				SetCredentials(ws)
				'
				' Ricerca Pazienti
				'
				Const DataNascita As String = Nothing
				Const LuogoNascita As String = Nothing
				Const Tessera As String = Nothing

				Dim oResponse = ws.PazientiCerca3(Cognome, Nome, DataNascita, AnnoNascita, LuogoNascita, CodiceFiscale, Tessera, My.Settings.MaxRecords)

				GestioneErrori.WriteInformation("PazientiCerca3 ({0}); Pazienti trovati: {1}", sMsg, oResponse.Length)

				Return oResponse

			End Using

		Catch ex As Exception
			GestioneErrori.WriteException("Errore da PazientiCerca3 ({0}); Message: {1}", sMsg, ex.Message)
			Throw
		End Try
	End Function


	''' <summary>
	''' Recupera il dettaglio del paziente
	''' </summary>
	Public Function PazienteDettaglio(IdPaziente As Guid) As PazientiDettaglio2ByIdResponsePazientiDettaglio2()
		Try
			Using ws As New PazientiSoapClient
				'
				'Setto le credenziali per connettermi al SAC
				SetCredentials(ws)

				Dim oResponse = ws.PazientiDettaglio2ById(IdPaziente.ToString)
				GestioneErrori.WriteInformation("PazientiDettaglio2ById ({0}); Pazienti trovati: {1}", IdPaziente.ToString, oResponse.Count)

				'
				' CONTROLLO SULL'ANAGRAFICA FUSA, NEL CASO LO SIA, RICERCO IL RECORD PADRE
				'
				If oResponse.Count = 1 Then
					If Not String.IsNullOrEmpty(oResponse(0).IdPazienteAttivo) Then
						oResponse = ws.PazientiDettaglio2ById(oResponse(0).IdPazienteAttivo)
						GestioneErrori.WriteInformation("PazientiDettaglio2ById IdPazienteAttivo ({0}); Pazienti trovati: {1}", IdPaziente.ToString, oResponse.Count)
					End If
				End If

				Return oResponse

			End Using
		Catch ex As Exception
			GestioneErrori.WriteException("Errore da PazientiDettaglio2ById ({0}); Message: {1}", IdPaziente.ToString, ex.Message)
			Throw
		End Try
	End Function


	''' <summary>
	''' Recupera il dettaglio del paziente per Provenienza + IdProvenienza
	''' </summary>
	Public Function PazienteDettaglioPerIdProvenienza(Provenienza As String, IdProvenienza As String) As PazientiDettaglio2ByIdResponsePazientiDettaglio2()
		Try
			Using ws As New PazientiSoapClient
				'
				'Setto le credenziali per connettermi al SAC
				SetCredentials(ws)

				Dim oResponse = ws.PazientiDettaglio2ByIdProvenienza(Provenienza, IdProvenienza)
				GestioneErrori.WriteInformation("PazientiDettaglio2ByIdProvenienza ({0}, {1}); Pazienti trovati: {2}", Provenienza, IdProvenienza, oResponse.Count)

				If oResponse.Length = 1 Then
					'
					' ALTRA CHIAMATA PER AVERE L'OGGETTO PazientiDettaglio2ByIdResponsePazientiDettaglio2
					' RESTITUITO DAL METODO PazienteDettaglio
					'
					Dim gIdPaziente = New Guid(oResponse(0).Id)
					Return PazienteDettaglio(gIdPaziente)

				Else
					' PAZIENTE NON TROVATO : ESITO NULLO 
					Dim oRet(-1) As PazientiDettaglio2ByIdResponsePazientiDettaglio2
					Return oRet
				End If

			End Using
		Catch ex As Exception
			GestioneErrori.WriteException("Errore da PazientiDettaglio2ByIdProvenienza ({0}, {1}); Message: {2}", Provenienza, IdProvenienza, ex.Message)
			Throw
		End Try
	End Function

End Class