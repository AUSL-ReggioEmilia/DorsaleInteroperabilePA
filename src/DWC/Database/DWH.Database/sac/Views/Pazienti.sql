
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-05-05
-- Description:	Accecco al SAC lista pazienti
-- =============================================
CREATE VIEW [sac].[Pazienti]
AS
	SELECT [Id]

		,[Cognome]
		,[Nome]
		,[CodiceFiscale]
		,[DataNascita]
		,[Sesso]

		,[ComuneNascitaCodice] AS LuogoNascitaCodice
		,[ComuneNascitaNome] AS LuogoNascitaDescrizione

		,[Tessera] AS CodiceSanitario
		,[DataDecesso] 

		,[NazionalitaCodice]
		,[NazionalitaNome]

		,[ComuneDomCodice] AS DomicilioComuneCodice
		,[ComuneDomNome] AS DomicilioComuneDescrizione
		,[CapDom] AS DomicilioCap
		,[LocalitaDom] AS DomicilioLocalita
		,[IndirizzoDom] AS DomicilioIndirizzo	
		  	  
		,[ComuneResCodice] AS ResidenzaComuneCodice
		,[ComuneResNome] AS ResidenzaComuneDescrizione
		,[IndirizzoRes] AS ResidenzaIndirizzo		  
		,[CapRes] AS ResidenzaCap

		-- Provenienza anagrafica
		,[Provenienza] AS NomeAnagraficaErogante
		,[IdProvenienza] AS CodiceAnagraficaErogante

		-- Dati di Consenso
		,[ConsensoAziendaleCodice]
		,[ConsensoAziendaleDescrizione]
		,[ConsensoAziendaleData]

		,[ConsensoSoleCodice]
		,[ConsensoSoleDescrizione]
		,[ConsensoSoleData]

		--Fusioni
		,[FusioneId]
		,[FusioneProvenienza]
		,[FusioneIdProvenienza]

		,[Disattivato]

	FROM [dbo].[SAC_Pazienti] P WITH(NOLOCK)
	WHERE P.[Id] <> '00000000-0000-0000-0000-000000000000'