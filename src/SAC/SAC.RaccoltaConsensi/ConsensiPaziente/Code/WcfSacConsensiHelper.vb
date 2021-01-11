Imports Wcf.SacConsensi	'tipi esposti dal webservice SacConsensi
Imports System.ComponentModel
Imports Wcf.SacPazienti

<DataObject(True)>
Public Class WcfSacConsensiHelper

	Private Shared Sub SetCredentials(ByVal oWs As ConsensiSoapClient)

		'autenticazione in BASIC con utente e password lette da file di configurazione
		ServiceHelper.SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, My.Settings.SACUsername, My.Settings.SACPassword)

	End Sub


    ''' <summary>
    ''' Aggiunge il consenso al paziente passato
    ''' </summary>
    Public Shared Function ConsensoAggiungi(Paziente As PazientiDettaglio2ByIdResponsePazientiDettaglio2, TipoConsenso As TipoConsenso, Attributi As AttributiType, UtenteCorrente As Utente) As Boolean
        Try
            Using ws As New ConsensiSoapClient
                '
                'Setto le credenziali per connettermi al SAC
                SetCredentials(ws)

                ' CREO L'OGGETTO CONSENSO 
                Dim cons As New Consenso
                cons.DataStato = DateTime.Now
                cons.OperatoreId = UtenteCorrente.AccountName
                cons.OperatoreNome = UtenteCorrente.Nome
                cons.OperatoreCognome = UtenteCorrente.Cognome
                cons.OperatoreComputer = HttpContext.Current.Request.ServerVariables("REMOTE_HOST")

                ' DATI DEL PAZIENTE
                cons.PazienteCodiceFiscale = Paziente.CodiceFiscale
                cons.PazienteCognome = Paziente.Cognome
                cons.PazienteComuneNascitaCodice = Paziente.ComuneNascitaCodice
                cons.PazienteDataNascita = Paziente.DataNascita
                cons.PazienteIdProvenienza = Paziente.IdProvenienza
                cons.PazienteNazionalitaCodice = Paziente.NazionalitaCodice
                cons.PazienteNome = Paziente.Nome
                cons.PazienteProvenienza = Paziente.Provenienza
                cons.PazienteTesseraSanitaria = Paziente.Tessera
                cons.Stato = True
                cons.Tipo = TipoConsenso
                cons.Attributi = Attributi

                Dim oRet = ws.ConsensiAggiungi(cons)

                GestioneErrori.WriteInformation("ConsensiAggiungi (Paziente: {0} Tipo: {1})", cons.PazienteCognome & " " & cons.PazienteNome, cons.Tipo.ToString)

                Return True

            End Using

        Catch ex As Exception
            GestioneErrori.WriteException("Errore da ConsensiAggiungi Message: {0}", ex.Message)
            Throw
        End Try

    End Function

    ''' <summary>
    ''' Nega il tipo di consenso passato (per ora solo il GENERICO)
    ''' </summary>
    Public Shared Function ConsensoNegatoAggiungi(Paziente As PazientiDettaglio2ByIdResponsePazientiDettaglio2, TipoConsenso As TipoConsenso, Attributi As AttributiType, UtenteCorrente As Utente) As Boolean
        Try
            Using ws As New ConsensiSoapClient
                '
                'Setto le credenziali per connettermi al SAC
                SetCredentials(ws)

                If TipoConsenso = TipoConsenso.Generico Then
                    ' CREO L'OGGETTO CONSENSO 
                    Dim cons As New Consenso
                    cons.OperatoreId = UtenteCorrente.AccountName
                    cons.OperatoreNome = UtenteCorrente.Nome
                    cons.OperatoreCognome = UtenteCorrente.Cognome
                    cons.OperatoreComputer = HttpContext.Current.Request.ServerVariables("REMOTE_HOST")

                    ' DATI DEL PAZIENTE
                    cons.PazienteCodiceFiscale = Paziente.CodiceFiscale
                    cons.PazienteCognome = Paziente.Cognome
                    cons.PazienteComuneNascitaCodice = Paziente.ComuneNascitaCodice
                    cons.PazienteDataNascita = Paziente.DataNascita
                    cons.PazienteIdProvenienza = Paziente.IdProvenienza
                    cons.PazienteNazionalitaCodice = Paziente.NazionalitaCodice
                    cons.PazienteNome = Paziente.Nome
                    cons.PazienteProvenienza = Paziente.Provenienza
                    cons.PazienteTesseraSanitaria = Paziente.Tessera
                    cons.Attributi = Attributi
                    cons.Stato = False

                    'Nego il GENERICO
                    cons.Tipo = TipoConsenso.Generico
                    cons.DataStato = DateTime.Now
                    ws.ConsensiAggiungi(cons)
                    GestioneErrori.WriteInformation("ConsensiAggiungi (Paziente: {0} Tipo: {1} Negato)", cons.PazienteCognome & " " & cons.PazienteNome, TipoConsenso.Generico.ToString)
                    'Nego il DOSSIER
                    cons.Tipo = TipoConsenso.Dossier
                    cons.DataStato = DateTime.Now
                    ws.ConsensiAggiungi(cons)
                    GestioneErrori.WriteInformation("ConsensiAggiungi (Paziente: {0} Tipo: {1} Negato)", cons.PazienteCognome & " " & cons.PazienteNome, TipoConsenso.Dossier.ToString)
                    'Nego il DOSSIERSTORICO
                    cons.Tipo = TipoConsenso.DossierStorico
                    cons.DataStato = DateTime.Now
                    ws.ConsensiAggiungi(cons)
                    GestioneErrori.WriteInformation("ConsensiAggiungi (Paziente: {0} Tipo: {1} Negato)", cons.PazienteCognome & " " & cons.PazienteNome, TipoConsenso.DossierStorico.ToString)
                Else
                    Throw New Exception("Tipo di consenso non gestito.")
                End If

                Return True

            End Using

        Catch ex As Exception
            GestioneErrori.WriteException("Errore da ConsensoNegatoAggiungi Message: {0}", ex.Message)
            Throw
        End Try

    End Function


    ''' <summary>
    ''' Lista dei valori per Relazione col minore
    ''' </summary>
    Public Function GetRelazioneMinore() As RelazioniConMinoreType

		Try
			Using ws As New ConsensiSoapClient
				'
				'Setto le credenziali per connettermi al SAC
				SetCredentials(ws)

				Return ws.RelazioniConMinoreCerca()

			End Using
		Catch ex As Exception
			GestioneErrori.WriteException("Errore da RelazioniConMinoreCerca(); Message: {0}", ex.Message)
			Throw
		End Try

	End Function


End Class