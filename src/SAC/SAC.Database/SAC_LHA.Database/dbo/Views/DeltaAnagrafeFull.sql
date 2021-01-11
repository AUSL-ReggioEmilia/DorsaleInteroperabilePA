

-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Restituisce gli IdPersona LHA per i quali sono state trovate differenze nel record anagrafico su SAC e quello su dbo.AppCn_Anagrafe
-- Modify date: 2014-04-02 -ETTORE: sostituito gli alias a SAC.DiaionariLhaComuni e SAC.DizionariLhaNazioni con le tabelle interne in SacConnLha
-- Modify date: 2019-01-22 -ETTORE: aggiunto la transcodifica del codice terminazione 
-- =============================================
CREATE VIEW [dbo].[DeltaAnagrafeFull]
AS
SELECT     
	 A.IdPersona AS IdLha
	, P.Id AS IdSac
	,'Paziente' AS Motivo
	
FROM         
	(SELECT CAST(IdPersona AS VARCHAR(16)) IdLha
			,Anagrafe.*
			,DizComuneNascita.IstatComune AS IstatComuneNascita
			,DizNazionalita.IstatNazione AS IstatNazionalita
			,DizComuneResidenza.IstatComune AS IstatComuneResidenza
			,DizComuneDomicilio.IstatComune AS IstatComuneDomicilio
			--
			-- Restituzione del codice terminazione transcodificato; se non trova transcodifica restituisce il valore di LHA
			--
			,ISNULL(CT.Codice, Anagrafe.CodiceMotivoTerminazione) AS CodiceMotivoTerminazioneTranscodificato
			,ISNULL(CT.Descrizione, Anagrafe.DescrizioneMotivoTerminazione) AS DescrizioneMotivoTerminazioneTranscodificato
				
	FROM dbo.AppCn_Anagrafe AS Anagrafe WITH(NOLOCK) 
		LEFT JOIN DizionariLhaComuni AS DizComuneNascita WITH(NOLOCK)
			ON Anagrafe.CodiceInternoComuneNascita = DizComuneNascita.CodiceInternoComune
		LEFT JOIN DizionariLhaNazioni AS DizNazionalita WITH(NOLOCK)
			ON Anagrafe.CodiceInternoNazionalita = DizNazionalita.CodiceInternoNazione
		LEFT JOIN DizionariLhaComuni AS DizComuneResidenza WITH(NOLOCK)
			ON Anagrafe.CodiceInternoComResidenza = DizComuneResidenza.CodiceInternoComune
		LEFT JOIN DizionariLhaComuni AS DizComuneDomicilio WITH(NOLOCK)
			ON Anagrafe.CodiceInternoComDomicilio = DizComuneDomicilio.CodiceInternoComune
		--Transcodifica del codice terminazione proveniente da LHA
		LEFT JOIN dbo.SacFullSyncDizionarioTerminazioni AS CT
			ON Anagrafe.CodiceMotivoTerminazione = CT.CodiceEsterno
				
	WHERE Anagrafe.IdVincenteFusione IS NULL
		AND Anagrafe.Annullato = 'N'
		AND Anagrafe.CodiceFiscale IS NOT NULL
		) AS A
	LEFT JOIN (SELECT * FROM dbo.SacFullSyncLhaPazienti WITH (nolock) 
				WHERE (Disattivato = 0)
				) AS P
		ON A.IdLha = P.IdLHA
    
WHERE	(
			( ISNULL(A.TesseraSanitaria,'') <> ISNULL(P.Tessera,'')
			OR ISNULL(A.CodiceFiscale,'') <> ISNULL(P.CodiceFiscale,'')
			OR ISNULL(A.Cognome,'') <> ISNULL(P.Cognome	,'')
			OR ISNULL(A.Nome,'') <> ISNULL(P.Nome,'')
			OR ISNULL(A.Sesso,'') <> ISNULL(P.Sesso,'')
			OR ISNULL(A.DataNascita,'') <> ISNULL(P.DataNascita, '')
			
			OR ISNULL(A.IstatComuneNascita, '000000') <> ISNULL(P.ComuneNascitaCodice, '000000')
                    OR ISNULL(A.IstatNazionalita, '000') <> ISNULL(P.NazionalitaCodice, '000')
                    OR ISNULL(A.IstatComuneResidenza, '000000') <> ISNULL(P.ComuneResCodice, '000000')
                    OR ISNULL(A.IstatComuneDomicilio, '000000') <> ISNULL(P.ComuneDomCodice, '000000')


			OR ISNULL(A.IndirizzoResidenza, '') <> ISNULL(P.IndirizzoRes, '')
			OR ISNULL(A.IndirizzoDomicilio, '') <> ISNULL(P.IndirizzoDom,'')

			OR (ISNULL(A.CAPResidenza, '') <> ISNULL(P.CapRes, '')
				AND NOT A.CAPResidenza IS NULL) -- Non confronta se su LHA è NULL
		
			OR (ISNULL(A.CAPDomicilio, '') <> ISNULL(P.CapDom,'')
				AND NOT A.CAPDomicilio IS NULL) -- Non confronta se su LHA è NULL

          OR ISNULL(RIGHT('000' + CAST(A.CodiceASLAssistenza AS VARCHAR(3)), 3), '000')<> ISNULL(P.CodiceAslAss, '000')
          OR ISNULL(RIGHT('000' + CAST(A.CodiceASLResidenza AS VARCHAR(3)), 3), '000')<> ISNULL(P.CodiceAslRes, '000')

			OR ISNULL(A.DataInizioAssistenza, '') <> ISNULL(P.DataInizioAss, '')
		    OR ISNULL(A.DataTerminazioneAssistenza, '') <> ISNULL(P.DataTerminazioneAss, '')
		    OR ISNULL(A.DataScadenzaAssistenza, '') <> ISNULL(P.DataScadenzaAss, '')

			OR ISNULL(A.CodiceMedicoMMG, 0) <> ISNULL(P.CodiceMedicoDiBase, 0)
			OR ISNULL(A.CognomeNomeMedicoMMG,'') <> ISNULL(P.CognomeNomeMedicoDiBase,'')
			OR ISNULL(A.CodiceFiscaleMedicoMMG,'') <> ISNULL(P.CodiceFiscaleMedicoDiBase,'')
			OR ISNULL(A.DataSceltaMedicoMMG, '') <> ISNULL(P.DataSceltaMedicoDiBase, '')
			
			OR ISNULL(A.Telefono1,'') <> ISNULL(P.Telefono1,'')
			OR ISNULL(A.Telefono2,'') <> ISNULL(P.Telefono2,'')
			OR ISNULL(A.Telefono3,'') <> ISNULL(P.Telefono3,'')

			--MODIFICA ETTORE 2019-01-22: eseguo confronto LHA - SAC usando il codice e la descrizione LHA transcodificati
			OR ISNULL(A.CodiceMotivoTerminazioneTranscodificato,'') <> ISNULL(P.CodiceTerminazione,'')
			OR ISNULL(A.DescrizioneMotivoTerminazioneTranscodificato,'') <> ISNULL(P.DescrizioneTerminazione,'')

			--Non mappato nell'orch., OR A.CodiceZonaSubcomResidenza <> P.SubComuneRes
			--Non mappato nell'orch., OR A.DataDecorrenzaResidenza <> P.DataDecorrenzaRes
			--Non mappato nell'orch., OR A.CodiceZonaSubcomDomicilio <> P.SubComuneDom

			--OR A.CodiceDistrettoAslAssistenza <> [non trovata corrispondenza nel SAC]
			--OR A.CodiceDistrettoAslResidenza <> [non trovata corrispondenza nel SAC]
			--OR A.CodiceRegionaleMedicoMMG <> [non trovata corrispondenza nel SAC]
			--OR A.MotivoTerminazioneIndicaMorte <> [non trovata corrispondenza nel SAC]
			)
		--
		-- Non presenti su SAC
		--
		OR P.Id IS NULL
		)
	--
	-- Non già nella DropTable da inviare
	--
	AND NOT EXISTS (SELECT *
					FROM dbo.PazientiDropTable dt WITH (nolock) 
					WHERE dt.IdLha = A.IdPersona AND dt.Inviato = 0)


GO



GO


