Imports Dwh.DataAccess.Wcf.Types.Prescrizioni

Public Class SacHelper

	Private Const cPROVENIENZADIRICERCA As String = "SOLE"

	''' <summary>
	''' CERCA O INSERIECE IL PAZIENTE, RITORNA IL SUO ID IN IDPaziente
	''' </summary>
	Public Shared Sub PazientiOutputCercaAggancioPaziente(Presc As PrescrizioneType, ByRef IDPaziente As Guid)

		'
		' VALORIZZO ALCUNI PARAMETRI PER LA STORED PROCEDURE
		'
		Dim ProvenienzaDiRicerca As String = cPROVENIENZADIRICERCA

		Dim IdProvenienzaDiRicerca As String = ""
		If Presc.Paziente.CodiceFiscale IsNot Nothing AndAlso Presc.Paziente.CodiceFiscale.Length > 0 Then
			IdProvenienzaDiRicerca = "CF_" & Presc.Paziente.CodiceFiscale
		ElseIf Presc.Paziente.TesseraSanitaria IsNot Nothing AndAlso Presc.Paziente.TesseraSanitaria.Length > 0 Then
			IdProvenienzaDiRicerca = "TS_" & Presc.Paziente.TesseraSanitaria
		End If
		Dim IdProvenienzaDiInserimento As String = IdProvenienzaDiRicerca 'da usare in caso di inserimento della posizione
		Dim Tessera As String = Presc.Paziente.TesseraSanitaria
		Dim Cognome As String = Presc.Paziente.Cognome
		Dim Nome As String = Presc.Paziente.Nome
		Dim DataNascita As DateTime? = Presc.Paziente.DataNascita
		Dim Sesso As String = Nothing
		Dim ComuneNascitaCodice As String
		Dim NazionalitaCodice As String = Nothing
		Dim CodiceFiscale As String = Presc.Paziente.CodiceFiscale
		'-- Dati di residenza
		Dim ComuneResCodice As String = Nothing
		Dim SubComuneRes As String = Nothing
		Dim IndirizzoRes As String = Nothing
		Dim LocalitaRes As String = Nothing
		Dim CapRes As String = Nothing
		'-- Dati di domicilio
		Dim ComuneDomCodice As String = Nothing
		Dim SubComuneDom As String = Nothing
		Dim IndirizzoDom As String = Nothing
		Dim LocalitaDom As String = Nothing
		Dim CapDom As String = Nothing
		'-- Altri dati
		Dim IndirizzoRecapito As String = Nothing
		Dim LocalitaRecapito As String = Nothing
		Dim Telefono1 As String = Nothing
		Dim Telefono2 As String = Nothing
		Dim Telefono3 As String = Nothing

		Try
			If Presc.Paziente.LuogoNascita IsNot Nothing Then
				ComuneNascitaCodice = Presc.Paziente.LuogoNascita.Codice
			End If

			Using ta As New DataSetSACTableAdapters.PazientiOutputCercaAggancioPazienteTableAdapter

				Log.WriteInformation(String.Format("SAC.PazientiOutputCercaAggancioPaziente: Cognome={0}, Nome={1}, CodFisc={2}", Cognome.NullSafeToString("NULL"), Nome.NullSafeToString("NULL"), CodiceFiscale.NullSafeToString("NULL")))

				Dim dt = ta.GetData(ProvenienzaDiRicerca, IdProvenienzaDiRicerca, IdProvenienzaDiInserimento, Tessera, Cognome, Nome, DataNascita, Sesso, ComuneNascitaCodice, NazionalitaCodice, CodiceFiscale, ComuneResCodice, SubComuneRes, IndirizzoRes, LocalitaRes, CapRes, ComuneDomCodice, SubComuneDom, IndirizzoDom, LocalitaDom, CapDom, IndirizzoRecapito, LocalitaRecapito, Telefono1, Telefono2, Telefono3)
				If dt.Count = 0 Then
					Throw New CustomException("Errore PazientiOutputCercaAggancioPaziente output nullo", ErrorCodes.ErroreSAC)
				End If

				IDPaziente = dt(0).Id

				Log.WriteInformation(String.Format("SAC.PazientiOutputCercaAggancioPaziente: ESITO Id={0}", IDPaziente.ToString))

			End Using


		Catch ex As CustomException
			' LE CustomException PASSANO AL CHIAMANTE
			Throw

		Catch ex As Exception
			'
			' GESTISCO L'ERRORE DI MANCATO INSERIMENTO ANAGRAFICO E PASSO AL CHIAMANTE idPaziente=”00000000-0000-0000-0000-000000000000”
			'
			If ex.Message.Contains("PARAMETRI DI INSERIMENTO NON VALIDI") Then
				IDPaziente = Guid.Empty
				Log.WriteWarning(String.Format("Warning 'Parametri non validi' SAC.PazientiOutputCercaAggancioPaziente: Cognome={0}, Nome={1}, CodFisc={2} -- ESITO Id={3}", Cognome.NullSafeToString("NULL"), Nome.NullSafeToString("NULL"), CodiceFiscale.NullSafeToString("NULL"), IDPaziente.ToString))
			Else
				'
				' TUTTI GLI ALTRI ERRORI PASSANO AL CHIAMANTE
				'
				Throw
			End If
		End Try

	End Sub


End Class
