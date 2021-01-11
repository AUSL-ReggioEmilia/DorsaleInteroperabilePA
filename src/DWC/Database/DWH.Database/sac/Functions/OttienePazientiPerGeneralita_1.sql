


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-11-29
-- Description:	Cerca il paziente per generalità e ritorna anche tutti i pazienti fusi
-- Modify date: 2018-11-06 - ETTORE: Gestione Oscuramento paziente tramite tabella PazientiOscurati
-- =============================================
CREATE FUNCTION [sac].[OttienePazientiPerGeneralita]
(
  @MaxNumRow	INT = 1000	
, @Cognome		VARCHAR(64)=NULL
, @Nome			VARCHAR(64)=NULL
, @DataNascita	DATE=NULL
, @AnnoNascita	INTEGER=NULL
, @LuogoNascita VARCHAR(128)=NULL
, @CodiceSanitario VARCHAR(16)=NULL
)
RETURNS TABLE 
AS
RETURN 
(
	WITH PazientiAttivi AS (
	--
	-- Cerca i pazienti per generalità
	--
	SELECT TOP (@MaxNumRow) P.Id 
		, P.Cognome, P.Nome, P.CodiceFiscale, P.DataNascita, P.Sesso
		, P.LuogoNascitaCodice, P.LuogoNascitaDescrizione, 	P.CodiceSanitario, P.DataDecesso, P.NazionalitaCodice, P.NazionalitaNome
		, P.DomicilioComuneCodice, P.DomicilioComuneDescrizione, P.DomicilioCap, P.DomicilioLocalita, P.DomicilioIndirizzo
		, P.ResidenzaComuneCodice, P.ResidenzaComuneDescrizione, P.ResidenzaIndirizzo, P.ResidenzaCap
		, P.NomeAnagraficaErogante, P.CodiceAnagraficaErogante
		, NULL AS FusioneId, NULL AS FusioneProvenienza, NULL AS FusioneIdProvenienza
		, 0 Disattivato

	FROM [sac].Pazienti P
	WHERE   (P.Cognome LIKE @Cognome + '%' OR @Cognome IS NULL)
		AND (P.Nome LIKE @Nome + '%'  OR @Nome IS NULL)
		AND (P.LuogoNascitaDescrizione LIKE @LuogoNascita + '%' OR @LuogoNascita IS NULL)
		AND (YEAR(P.DataNascita) = @AnnoNascita OR @AnnoNascita IS NULL)
		AND (CONVERT(DATE, P.DataNascita) = @DataNascita OR @DataNascita IS NULL)
		AND (P.CodiceSanitario LIKE @CodiceSanitario + '%'  OR @CodiceSanitario IS NULL)

		AND P.Disattivato = 0
		-- Modify date: 2018-11-06 - ETTORE: Gestione Oscuramento paziente tramite tabella PazientiOscurati
		AND NOT EXISTS (SELECT * FROM [dbo].[OttieniPazienteOscuramenti](P.Id) 
								WHERE OscuraReferti = 1 AND OscuraRicoveri = 1 AND OscuraPrescrizioni = 1 AND OscuraNoteAnamnestiche = 1
								) 

	ORDER BY Cognome, Nome, DataNascita
	)

	SELECT *
	FROM PazientiAttivi

	UNION ALL
	--
	-- Aggiunge i pazienti Fusi degli attivi
	--
	SELECT PF.IdPazienteFuso AS Id 
		, P.Cognome, P.Nome, P.CodiceFiscale, P.DataNascita, P.Sesso
		, P.LuogoNascitaCodice, P.LuogoNascitaDescrizione, 	P.CodiceSanitario, P.DataDecesso, P.NazionalitaCodice, P.NazionalitaNome
		, P.DomicilioComuneCodice, P.DomicilioComuneDescrizione, P.DomicilioCap, P.DomicilioLocalita, P.DomicilioIndirizzo
		, P.ResidenzaComuneCodice, P.ResidenzaComuneDescrizione, P.ResidenzaIndirizzo, P.ResidenzaCap
		, PPF.NomeAnagraficaErogante, PPF.CodiceAnagraficaErogante
		, P.Id AS FusioneId, P.NomeAnagraficaErogante AS FusioneProvenienza, P.CodiceAnagraficaErogante AS FusioneIdProvenienza
		, PPF.Disattivato

	FROM PazientiAttivi P
		INNER JOIN [sac].[PazientiFusioni] AS PF
			ON PF.IdPazienti = P.Id

		INNER JOIN [sac].[Pazienti] AS PPF
			ON PF.IdPazienteFuso = PPF.Id
			AND PPF.Disattivato = 2
)