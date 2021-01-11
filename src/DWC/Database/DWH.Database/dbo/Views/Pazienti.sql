






-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-08-30
-- Description:	Accesso al SAC. Ritorna solo i pazienti ATTIVI e con cancellati
--					adatta alla ricerca del paziente il lista
-- Modify date: 2018-10-26 - ETTORE: gestione della tabella OscuramentiPaziente. Se Tutti i flag sono 1 allora non restituisco il paziente
--									Cancellato la parte di filtro che usa la PazientiCancellati
-- =============================================
CREATE VIEW [dbo].[Pazienti]
AS
/*

	MODIFICA ETTORE 2016-03-24: 
		1) Modificato il sinonimo [dbo].[SAC_Pazienti]: ora punta alla vista SAC.PazientiOutput3
		2) Aggiunti i campi relativi a Domicilio, Residenza, DataDecesso, Consenso Aziendale e Sole

*/
	SELECT [Id]
		  ,'ASMN' AS [AziendaErogante]
		  ,'SAC' AS [SistemaErogante]
		  ,CAST(NULL AS VARCHAR(64)) AS [RepartoErogante]
		  ,Tessera AS [CodiceSanitario]
		  ,[Sesso]
		  ,[Nome]
		  ,[Cognome]
		  ,[CodiceFiscale]
		  ,[DataNascita]
		  ,ComuneNascitaNome AS [LuogoNascita]
		  ,SOUNDEX([Nome]) AS [SoundexNome]
		  ,SOUNDEX([Cognome]) AS [SoundexCognome]
		  ,[DatiAnamnestici]
		  --
		  -- NUOVI CAMPI AGGIUNTI IL 2016-03-24
		  --
		  , Provenienza AS NomeAnagraficaErogante
		  , IdProvenienza AS CodiceAnagraficaErogante
		  , ComuneNascitaCodice AS LuogoNascitaCodice

		  , NazionalitaCodice
		  --VECCHIO	DA CANCELLARE DOPO MODIFICA
		  , NazionalitaNome
		  --NUOVO
		  , NazionalitaNome AS NazionalitaDescrizione

		  
		  --VECCHI DA CANCELLARE DOPO MODIFICA
		  , ComuneDomCodice AS DomicilioComuneCodice
		  , ComuneDomNome AS DomicilioComuneNome
		  --NUOVI
		  , ComuneDomCodice AS ComuneDomicilioCodice
		  , ComuneDomNome AS ComuneDomicilioDescrizione
		  
		  
		  , CapDom  AS DomicilioCap
		  , LocalitaDom  AS DomicilioLocalita
		  , IndirizzoDom  AS DomicilioIndirizzo		  
		  , ComuneResCodice AS ComuneResidenzaCodice	--ResidenzaComuneCodice
		  , ComuneResNome AS ComuneResidenzaDescrizione --ResidenzaComuneNome
		  , IndirizzoRes AS ResidenzaIndirizzo		  
		  , CapRes AS ResidenzaCap
		  , DataDecesso 
		  -- Dati di Consenso
		  , ConsensoAziendaleCodice
		  , ConsensoAziendaleDescrizione
		  , ConsensoAziendaleData
		  , ConsensoSoleCodice
		  , ConsensoSoleDescrizione
		  , ConsensoSoleData
	  
	FROM [dbo].[SAC_Pazienti] Pazienti WITH(NOLOCK)
	WHERE Pazienti.Disattivato = 0
		AND Pazienti.Id <> '00000000-0000-0000-0000-000000000000'
		--
		-- Verifico se per tale paziente non esista un oscuramento per tutti gli oggetti del database
		--
		AND NOT EXISTS (SELECT * FROM [dbo].[OttieniPazienteOscuramenti](Pazienti.Id) 
						WHERE OscuraReferti = 1 
							AND OscuraRicoveri = 1
							AND OscuraPrescrizioni = 1 
							AND OscuraNoteAnamnestiche = 1)

