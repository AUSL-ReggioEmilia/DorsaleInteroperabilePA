Imports System.Data
Imports Dwh.DataAccess.Wcf.Service.DWHDataSetTableAdapters
Imports Dwh.DataAccess.Wcf.Types.Prescrizioni

Public Class DwhHelper


	''' <summary>
	''' Salva o Aggiorna su DB l'intera prescrizione comprensiva di allegati
	''' </summary>
	''' <remarks></remarks>
	Public Shared Sub AggiungiOrAggiorna(Presc As PrescrizioneType, IdPazienteSAC As Guid)

		' PARAMETRI DELLA SP ExtPrescrizioniAggiungi
		'@IdEsternoPrescrizione			varchar (64)
		'@IdPaziente					uniqueidentifier
		'@DataModificaEsterno			datetime
		'@StatoCodice					tinyint
		'@TipoPrescrizione				varchar(32)
		'@DataPrescrizione				datetime
		'@NumeroPrescrizione			varchar(16)
		'@MedicoPrescrittoreCodiceFiscale	varchar(16)
		'@QuesitoDiagnostico			varchar(2048)
		'@Attributi						xml = NULL
		'-- Ritorna la PK del record inserito
		'@IdPrescrizione				uniqueidentifier = NULL OUTPUT
		'@DataPartizione				smalldatetime = NULL OUTPUT
		'@Azione						varchar(16) = NULL OUTPUT

		' DATI DI RITORNO DALLA ExtPrescrizioniAggiungi
		Dim gIDPrescrizione As Guid?
		Dim dDataPartizione As DateTime?
		Dim sAzione As String = ""

		' SERIALIZZO GLI ATTRIBUTI DELLA PRESCRIZIONE
		Dim msXmlAttributi As String = Nothing
		If Presc.Attributi IsNot Nothing AndAlso Presc.Attributi.Count > 0 Then
			msXmlAttributi = GenericDataContractSerializer.Serialize(Presc.Attributi)
		End If

		Dim Conn As New SqlClient.SqlConnection(My.Settings.DWHConnectionString)
		Dim Trans As SqlClient.SqlTransaction = Nothing

		' TRY CATCH PER GESTIRE LA TRANSAZIONE, TUTTE LE ECCEZIONI PASSANO FUORI
		Try
			Conn.Open()
			Trans = Conn.BeginTransaction

			' INSERIMENTO PRESCRIZIONE
			Using taPresc As New PrescrizioniAggiungiTableAdapter(Conn, Trans)
				taPresc.Fill(Presc.IdEsterno, IdPazienteSAC, Presc.DataModificaEsterno, Presc.StatoCodice,
							 Presc.TipoPrescrizione, Presc.DataPrescrizione, Presc.NumeroPrescrizione,
							 Presc.MedicoPrescrittoreCodiceFiscale, Presc.QuesitoDiagnostico, msXmlAttributi,
							 gIDPrescrizione, dDataPartizione, sAzione)
				If taPresc.ReturnValue <> 0 Then
					Debug.Assert(False, "Errore di configurazione tableadapter: Il command non è impostato in ExecuteMode=NonQuery !")
					Throw New CustomException(String.Format("ReturnValue: {0}", taPresc.ReturnValue), ErrorCodes.ErroreDWH)
				End If
			End Using
			Log.WriteInformation(String.Format("DWH.ExtPrescrizioniAggiungi: IDPrescrizione={0}, DataPartizione={1}, Azione={2}",
											   gIDPrescrizione.NullSafeToString("NULL"), dDataPartizione.NullSafeToString("NULL"), sAzione.NullSafeToString("NULL")))

			If String.IsNullOrEmpty(sAzione) Then
				'NESSUNA AZIONE: ESCO SENZA SEGNALARE ERRORE
			Else
				If sAzione = "UPDATE" Then
					' CANCELLO TUTTI GLI ALLEGATI
					Using taAllegati As New PrescrizioniAllegatiRimuoviTableAdapter(Conn, Trans)
						taAllegati.Fill(gIDPrescrizione, dDataPartizione, Nothing)
						If taAllegati.ReturnValue <> 0 Then
							Debug.Assert(False, "Errore di configurazione tableadapter: Il command non è impostato in ExecuteMode=NonQuery !")
							Throw New CustomException(String.Format("ReturnValue: {0}", taAllegati.ReturnValue), ErrorCodes.ErroreDWH)
						End If
					End Using

				End If

				If sAzione = "INSERT" Or sAzione = "UPDATE" Then

					' ALLEGATI DELLA PRESCRIZIONE
					For Each Allegato In Presc.Allegati
						' SERIALIZZO GLI EVENTUALI ATTRIBUTI DELL'ALLEGATO
						Dim sXmlAttributi As String = Nothing
						If Allegato.Attributi IsNot Nothing AndAlso Allegato.Attributi.Count > 0 Then
							sXmlAttributi = GenericDataContractSerializer.Serialize(Allegato.Attributi)
						End If

						' INSERISCO GLI ALLEGATI
						Using taAllegati As New PrescrizioniAllegatiAggiungiTableAdapter(Conn, Trans)
							taAllegati.Fill(gIDPrescrizione, dDataPartizione, Allegato.IdEsterno, Allegato.TipoContenuto, Allegato.Contenuto, sXmlAttributi, sAzione)
							If taAllegati.ReturnValue <> 0 Then
								Debug.Assert(False, "Errore di configurazione tableadapter: Il command non è impostato in ExecuteMode=NonQuery !")
								Throw New CustomException(String.Format("ReturnValue: {0}", taAllegati.ReturnValue), ErrorCodes.ErroreDWH)
							End If
						End Using
					Next

					'
					' INVOCO LA SP DI NOTIFICA SE IL PAZIENTE NON E' NULLO
					'
					If IdPazienteSAC.CompareTo(Guid.Empty) <> 0 Then
						' Valori possibili: 0=Inserimento, 1=Modifica, 2=Cancellazione
						Dim iOperazione As Integer
						If sAzione = "INSERT" Then
							iOperazione = 0
						ElseIf sAzione = "UPDATE" Then
							iOperazione = 1
						End If

						Using taNoti As New PrescrizioniNotificaTableAdapter(Conn, Trans)
							taNoti.Fill(gIDPrescrizione, dDataPartizione, iOperazione)
							If taNoti.ReturnValue <> 0 Then
								Debug.Assert(False, "Errore di configurazione tableadapter: Il command non è impostato in ExecuteMode=NonQuery !")
								Throw New CustomException(String.Format("ReturnValue: {0}", taNoti.ReturnValue), ErrorCodes.ErroreDWH)
							End If
						End Using
					End If

				End If

			End If

			'
			' COMMIT DELLA TRANSAZIONE
			'
			Trans.Commit()


		Catch
			If Trans IsNot Nothing Then Trans.Rollback()
			' LE ECCEZIONI SONO GESTITE ESTERNAMENTE
			Throw

		Finally
			If Conn IsNot Nothing AndAlso Conn.State = ConnectionState.Open Then
				Conn.Close()
			End If
		End Try

	End Sub


	''' <summary>
	''' Rimuove su DB l'intera prescrizione comprensiva di allegati
	''' </summary>
	Public Shared Sub Rimuovi(IdEsterno As String, DataModificaEsterno As DateTime)

		Dim Conn As New SqlClient.SqlConnection(My.Settings.DWHConnectionString)
		Dim Trans As SqlClient.SqlTransaction = Nothing

		' VALORI RESTITUITI DALLA ExtPrescrizioniEsiste
		Dim gIDPrescrizione As Guid?
		Dim dDataPartizione As DateTime?
		Dim dDataModificaEsternoSuDb As DateTime?

		Try
			Conn.Open()
			Trans = Conn.BeginTransaction


			'
			' RECUPERO I DATI DELLA PRESCRIZIONE
			'
			Using taPrEsis As New PrescrizioniEsisteTableAdapter(Conn, Trans)
				taPrEsis.Fill(IdEsterno, gIDPrescrizione, dDataPartizione, dDataModificaEsternoSuDb)
				If taPrEsis.ReturnValue <> 0 Then
					Debug.Assert(False, "Errore di configurazione tableadapter: Il command non è impostato in ExecuteMode=NonQuery !")
					Throw New CustomException(String.Format("ReturnValue: {0}", taPrEsis.ReturnValue), ErrorCodes.ErroreDWH)
				End If
			End Using

			If gIDPrescrizione.HasValue Then
				'
				' SE LA DATAMODIFICAESTERNO DEL RECORD SU DB E' ANTECEDENTE O UGUALE A QUELLA PASSATA DAL CHIAMANTE
				' SIGNIFICA CHE POSSO CANCELLARE IN QUANTO LA PRESCRIZIONE E' LA STESSA O ADDIRITTURA PIU' VECCHIA;
				' ALTRIMENTI SU DB HO UNA VERSIONE PIU' RECENTE DI QUELLA IN MANO AL CHIAMANTE E NON LA CANCELLO.
				'
				If dDataModificaEsternoSuDb.Value <= DataModificaEsterno Then
					'
					' INVOCO LA SP DI NOTIFICA
					'
					' Valori possibili: 0=Inserimento, 1=Modifica, 2=Cancellazione
					Const iOperazione As Integer = 2
					Using taNoti As New PrescrizioniNotificaTableAdapter(Conn, Trans)
						taNoti.Fill(gIDPrescrizione.Value, dDataPartizione.Value, iOperazione)
						If taNoti.ReturnValue <> 0 Then
							Debug.Assert(False, "Errore di configurazione tableadapter: Il command non è impostato in ExecuteMode=NonQuery !")
							Throw New CustomException(String.Format("ReturnValue: {0}", taNoti.ReturnValue), ErrorCodes.ErroreDWH)
						End If
					End Using

					'
					' INVOCO LA SP DI CANCELLAZIONE PRESCRIZIONE
					'
					Log.WriteInformation(String.Format("DWH.ExtPrescrizioniRimuovi: IdEsterno={0}, DataModificaEsterno={1}", IdEsterno, DataModificaEsterno.ToShortDateString))
					Using taPresc As New PrescrizioniRimuoviTableAdapter(Conn, Trans)
						taPresc.Fill(gIDPrescrizione, dDataPartizione)
						If taPresc.ReturnValue <> 0 Then
							Debug.Assert(False, "Errore di configurazione tableadapter: Il command non è impostato in ExecuteMode=NonQuery !")
							Throw New CustomException(String.Format("ReturnValue: {0}", taPresc.ReturnValue), ErrorCodes.ErroreDWH)
						End If
					End Using
				Else
					Log.WriteWarning(String.Format("DWH.ExtPrescrizioniEsiste; tentativo di eliminare una prescrizione con DataModificaEsterno più recente: IdEsterno={0}, DataModificaEsterno={1}", IdEsterno, DataModificaEsterno.ToShortDateString))
					'	QUESTO LO SEGNALO CON UN ECCEZIONE
					Throw New CustomException("La prescrizione presente su database è più recente di quella che si vuole cancellare", ErrorCodes.OperazioneNonEseguita)
				End If

			Else
				Log.WriteWarning(String.Format("DWH.ExtPrescrizioniEsiste; la prescrizione non esiste: IdEsterno={0}, DataModificaEsterno={1}", IdEsterno, DataModificaEsterno.ToShortDateString))
				'	QUESTO LO SEGNALO CON UN ECCEZIONE
				Throw New CustomException("Prescrizione non trovata", ErrorCodes.DatoNonTrovato)
			End If
			'
			' COMMIT DELLA TRANSAZIONE
			'
			Trans.Commit()

		Catch
			If Trans IsNot Nothing Then Trans.Rollback()

			' LE ECCEZIONI SONO GESTITE ESTERNAMENTE
			Throw

		Finally
			If Conn IsNot Nothing AndAlso Conn.State = ConnectionState.Open Then
				Conn.Close()
			End If
		End Try

	End Sub

End Class
