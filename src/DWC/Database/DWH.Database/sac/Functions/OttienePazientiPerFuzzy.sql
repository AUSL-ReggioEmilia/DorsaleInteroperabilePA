


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-05-05
-- Description:	Cerca il paziente con modalità fuzzy e ritorna anche tutti i pazienti fusi
-- Modify date: 2018-11-06 - ETTORE: Gestione Oscuramento paziente tramite tabella PazientiOscurati
-- =============================================
CREATE FUNCTION [sac].[OttienePazientiPerFuzzy]
(
  @MaxNumRow	INT = 1000	
, @Cognome 		VARCHAR (64)= NULL	
, @Nome 		VARCHAR (64)= NULL
, @DataNascita		DATE= NULL
, @AnnoNascita		INT= NULL
, @CodiceFiscale 	VARCHAR (16)= NULL
, @CodiceSanitario 	VARCHAR (16)= NULL
, @Anagrafica 		VARCHAR (16)= NULL
, @IdAnagrafica		VARCHAR (64)= NULL

)
RETURNS 
@Pazienti TABLE 
(
	[Id] [uniqueidentifier] NOT NULL,
	[Cognome] [varchar](64) NULL,
	[Nome] [varchar](64) NULL,
	[CodiceFiscale] [varchar](16) NULL,
	[DataNascita] [datetime] NULL,
	[Sesso] [varchar](1) NULL,
	[LuogoNascitaCodice] [varchar](6) NULL,
	[LuogoNascitaDescrizione] [varchar](128) NULL,
	[CodiceSanitario] [varchar](16) NULL,
	[DataDecesso] [datetime] NULL,
	[NazionalitaCodice] [varchar](3) NULL,
	[NazionalitaDescrizione] [varchar](128) NULL,
	[DomicilioComuneCodice] [varchar](6) NULL,
	[DomicilioComuneDescrizione] [varchar](128) NULL,
	[DomicilioCap] [varchar](8) NULL,
	[DomicilioLocalita] [varchar](128) NULL,
	[DomicilioIndirizzo] [varchar](256) NULL,
	[ResidenzaComuneCodice] [varchar](6) NULL,
	[ResidenzaComuneDescrizione] [varchar](128) NULL,
	[ResidenzaIndirizzo] [varchar](256) NULL,
	[ResidenzaCap] [varchar](8) NULL,
	[NomeAnagraficaErogante] [varchar](16) NOT NULL,
	[CodiceAnagraficaErogante] [varchar](64) NOT NULL,
	[ConsensoAziendaleCodice] [int] NULL,
	[ConsensoAziendaleDescrizione] [varchar](64) NULL,
	[ConsensoAziendaleData] [datetime] NULL,
	[ConsensoSoleCodice] [int] NULL,
	[ConsensoSoleDescrizione] [varchar](64) NULL,
	[ConsensoSoleData] [datetime] NULL,
	[FusioneId] [uniqueidentifier] NULL,
	[FusioneProvenienza] [varchar](16) NULL,
	[FusioneIdProvenienza] [varchar](64) NULL,
	[Disattivato] [tinyint] NOT NULL
)
AS
BEGIN

DECLARE @IdPaziente	UNIQUEIDENTIFIER

    -------------------------------------------------------------------------------------------------------------------------
	--  Ricerco in PazientiRiferimenti il Paziente per Anagrafica+Codice
	-- La funzione dbo.GetPazientiIdByRiferimento() restituisce l'attivo
	-------------------------------------------------------------------------------------------------------------------------

	SET @IdPaziente = dbo.GetPazientiIdByRiferimento(@Anagrafica, @IdAnagrafica)
	IF @IdPaziente IS NOT NULL
	BEGIN
		INSERT @Pazienti
		SELECT TOP (@MaxNumRow) P.Id 
			, P.Cognome, P.Nome, P.CodiceFiscale, P.DataNascita, P.Sesso
			, P.LuogoNascitaCodice, P.LuogoNascitaDescrizione, 	P.CodiceSanitario, P.DataDecesso, P.NazionalitaCodice, P.NazionalitaNome
			, P.DomicilioComuneCodice, P.DomicilioComuneDescrizione, P.DomicilioCap, P.DomicilioLocalita, P.DomicilioIndirizzo
			, P.ResidenzaComuneCodice, P.ResidenzaComuneDescrizione, P.ResidenzaIndirizzo, P.ResidenzaCap
			, P.NomeAnagraficaErogante, P.CodiceAnagraficaErogante
			, P.ConsensoAziendaleCodice, P.ConsensoAziendaleDescrizione, P.ConsensoAziendaleData
			, P.ConsensoSoleCodice, P.ConsensoSoleDescrizione, P.ConsensoSoleData
			, P.FusioneId, P.FusioneProvenienza, P.FusioneIdProvenienza
			, P.Disattivato
		FROM [sac].[Pazienti] AS P
		WHERE P.Id = @IdPaziente
	END
	--
	-- Aggiungo per Cognome e Nome
	--
	INSERT @Pazienti
	SELECT TOP (@MaxNumRow) P.Id 
		, P.Cognome, P.Nome, P.CodiceFiscale, P.DataNascita, P.Sesso
		, P.LuogoNascitaCodice, P.LuogoNascitaDescrizione, 	P.CodiceSanitario, P.DataDecesso, P.NazionalitaCodice, P.NazionalitaNome
		, P.DomicilioComuneCodice, P.DomicilioComuneDescrizione, P.DomicilioCap, P.DomicilioLocalita, P.DomicilioIndirizzo
		, P.ResidenzaComuneCodice, P.ResidenzaComuneDescrizione, P.ResidenzaIndirizzo, P.ResidenzaCap
		, P.NomeAnagraficaErogante, P.CodiceAnagraficaErogante
		, P.ConsensoAziendaleCodice, P.ConsensoAziendaleDescrizione, P.ConsensoAziendaleData
		, P.ConsensoSoleCodice, P.ConsensoSoleDescrizione, P.ConsensoSoleData
		, P.FusioneId, P.FusioneProvenienza, P.FusioneIdProvenienza
		, P.Disattivato
	FROM [sac].[Pazienti] AS P
	WHERE	P.Nome = @Nome AND NOT P.Nome IS NULL
		AND P.Cognome = @Cognome AND NOT P.Cognome IS NULL
		AND P.CodiceSanitario = @CodiceSanitario AND NOT P.CodiceSanitario IS NULL
		AND P.Disattivato = 0
		AND NOT EXISTS(SELECT * FROM @Pazienti AS Pazienti WHERE Pazienti.id = P.id)
	--
	-- Aggiungo per Cognome e Nome e CodiceFiscale
	--
	INSERT @Pazienti
	SELECT TOP (@MaxNumRow) P.Id 
		, P.Cognome, P.Nome, P.CodiceFiscale, P.DataNascita, P.Sesso
		, P.LuogoNascitaCodice, P.LuogoNascitaDescrizione, 	P.CodiceSanitario, P.DataDecesso, P.NazionalitaCodice, P.NazionalitaNome
		, P.DomicilioComuneCodice, P.DomicilioComuneDescrizione, P.DomicilioCap, P.DomicilioLocalita, P.DomicilioIndirizzo
		, P.ResidenzaComuneCodice, P.ResidenzaComuneDescrizione, P.ResidenzaIndirizzo, P.ResidenzaCap
		, P.NomeAnagraficaErogante, P.CodiceAnagraficaErogante
		, P.ConsensoAziendaleCodice, P.ConsensoAziendaleDescrizione, P.ConsensoAziendaleData
		, P.ConsensoSoleCodice, P.ConsensoSoleDescrizione, P.ConsensoSoleData
		, P.FusioneId, P.FusioneProvenienza, P.FusioneIdProvenienza
		, P.Disattivato
	FROM [sac].[Pazienti] AS P
	WHERE	Nome = @Nome AND NOT Nome IS NULL
		AND Cognome = @Cognome AND NOT Cognome IS NULL
		AND CodiceFiscale = @CodiceFiscale AND NOT CodiceFiscale IS NULL
		AND Disattivato = 0
		AND NOT EXISTS(SELECT * FROM @Pazienti AS Pazienti WHERE Pazienti.id = P.id)
	--
	-- Aggiungo per Cognome e Nome e Data o Anno nascita
	--
	INSERT @Pazienti
	SELECT TOP (@MaxNumRow) P.Id 
		, P.Cognome, P.Nome, P.CodiceFiscale, P.DataNascita, P.Sesso
		, P.LuogoNascitaCodice, P.LuogoNascitaDescrizione, 	P.CodiceSanitario, P.DataDecesso, P.NazionalitaCodice, P.NazionalitaNome
		, P.DomicilioComuneCodice, P.DomicilioComuneDescrizione, P.DomicilioCap, P.DomicilioLocalita, P.DomicilioIndirizzo
		, P.ResidenzaComuneCodice, P.ResidenzaComuneDescrizione, P.ResidenzaIndirizzo, P.ResidenzaCap
		, P.NomeAnagraficaErogante, P.CodiceAnagraficaErogante
		, P.ConsensoAziendaleCodice, P.ConsensoAziendaleDescrizione, P.ConsensoAziendaleData
		, P.ConsensoSoleCodice, P.ConsensoSoleDescrizione, P.ConsensoSoleData
		, P.FusioneId, P.FusioneProvenienza, P.FusioneIdProvenienza
		, P.Disattivato
	FROM [sac].[Pazienti] AS P
	WHERE	Nome = @Nome AND NOT Nome IS NULL
		AND Cognome = @Cognome AND NOT Cognome IS NULL
		AND (
				(CONVERT(DATE, DataNascita) = @DataNascita AND NOT DataNascita IS NULL)
				OR
				(YEAR(DataNascita) = @AnnoNascita AND NOT DataNascita IS NULL)
			)
		AND Disattivato = 0
		AND NOT EXISTS(SELECT * FROM @Pazienti AS Pazienti WHERE Pazienti.id = P.id)
	--
	-- Aggiungo i pazienti fusi di quelli già trovati
	--
	INSERT @Pazienti
	SELECT PF.Id
		, P.Cognome, P.Nome, P.CodiceFiscale, P.DataNascita, P.Sesso
		, P.LuogoNascitaCodice, P.LuogoNascitaDescrizione, P.CodiceSanitario,P.DataDecesso, P.NazionalitaCodice, P.NazionalitaDescrizione
		, P.DomicilioComuneCodice, P.DomicilioComuneDescrizione, P.DomicilioCap, P.DomicilioLocalita, P.DomicilioIndirizzo
		, P.ResidenzaComuneCodice, P.ResidenzaComuneDescrizione, P.ResidenzaIndirizzo, P.ResidenzaCap
		, PF.NomeAnagraficaErogante, PF.CodiceAnagraficaErogante
		, P.ConsensoAziendaleCodice, P.ConsensoAziendaleDescrizione, P.ConsensoAziendaleData
		, P.ConsensoSoleCodice, P.ConsensoSoleDescrizione, P.ConsensoSoleData
		, PF.FusioneId, PF.FusioneProvenienza, PF.FusioneIdProvenienza
		, PF.Disattivato

	FROM sac.Pazienti PF
		INNER JOIN @Pazienti AS P 
			ON P.Id = PF.FusioneId
				AND PF.Disattivato = 2
		AND NOT EXISTS(SELECT * FROM @Pazienti AS Pazienti WHERE Pazienti.id = PF.id)
	--
	-- Rimuovo i cancellati
	--
	DELETE @Pazienti
	FROM @Pazienti P
	WHERE 
		-- Modify date: 2018-11-06 - ETTORE: Gestione Oscuramento paziente tramite tabella PazientiOscurati
		EXISTS (SELECT * FROM [dbo].[OttieniPazienteOscuramenti](P.Id) 
								WHERE OscuraReferti = 1 AND OscuraRicoveri = 1 AND OscuraPrescrizioni = 1 AND OscuraNoteAnamnestiche = 1
								) 
	RETURN 
END