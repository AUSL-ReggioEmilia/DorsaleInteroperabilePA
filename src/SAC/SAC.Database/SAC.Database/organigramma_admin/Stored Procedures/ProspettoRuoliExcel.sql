



-- =============================================
-- Author:		Kyrylo A.
-- Create date: 2020-10-26
--
-- Description:	Ottiene il prospetto di tutti i ruoli presenti, oppure del ruolo passato (IdRuolo) per la creazione dell'Excel
-- =============================================
CREATE PROCEDURE [organigramma_admin].[ProspettoRuoliExcel]
(
 @IdRuolo UNIQUEIDENTIFIER = NULL
)
AS
BEGIN

	--
	-- RUOLO/I
	--
	SELECT DISTINCT
		  RU.ID AS IdRuolo,
		  RU.Codice AS CodiceRuolo,
		  RU.Descrizione AS DescrizioneRuolo

	FROM organigramma.Ruoli AS RU
	
	WHERE RU.Attivo = 1 AND (RU.ID = @IdRuolo OR @IdRuolo IS NULL)


	--
	-- ASSOCIAZIONE RUOLI-UTENTI
	--
	SELECT DISTINCT
		  RU.IdRuolo,
		  RU.RuoloCodice AS CodiceRuolo,
		  RU.IdUtente,
		  RU.Utente,
		  RU.TipoAbilitazione,
		  RU.GruppoAbilitante

	FROM organigramma_da.RuoliUtenti2 AS RU

	WHERE RU.IdRuolo = @IdRuolo OR @IdRuolo IS NULL


	--
	-- ASSOCIAZIONE RUOLO/I-ACCESSI
	--
		-- RUOLI ACCESSI
		SELECT DISTINCT
			RU.ID AS IdRuolo,
			RU.Codice AS CodiceRuolo,
			RU.Descrizione AS DescrizioneRuolo,
			AR.Codice AS CodiceAccesso,
			AR.Descrizione AS DescrizioneAccessi

		FROM organigramma.Ruoli AS RU

			LEFT JOIN organigramma.RuoliAttributi RA 
				ON RA.IdRuolo = RU.ID
			INNER JOIN organigramma.Attributi AR 
				ON AR.Codice = RA.CodiceAttributo AND AR.UsoPerRuolo = 1

		WHERE RU.Attivo = 1 AND (RU.ID = @IdRuolo OR @IdRuolo IS NULL)

		UNION ALL

		-- RUOLI-SISTEMI ACCESSI
		SELECT DISTINCT
			RU.ID AS IdRuolo,
			RU.Codice AS CodiceRuolo,
			RU.Descrizione AS DescrizioneRuolo,
			AST.Codice AS CodiceAccesso,
			AST.Descrizione + ' per il sistema ' + S.Descrizione + ' di ' + S.CodiceAzienda

		FROM organigramma.Ruoli AS RU

			LEFT JOIN organigramma.RuoliSistemi RS
				ON RS.IdRuolo = RU.ID
			INNER JOIN organigramma.RuoliSistemiAttributi RSA 
				ON RS.ID = RSA.IdRuoloSistema
			INNER JOIN organigramma.Attributi AST 
				ON AST.Codice = RSA.CodiceAttributo AND AST.UsoPerSistemaErogante = 1
			INNER JOIN organigramma.Sistemi S
				ON S.ID = RS.IdSistema
	
		WHERE RU.Attivo = 1 AND S.Attivo = 1 AND (RU.ID = @IdRuolo OR @IdRuolo IS NULL)

		UNION ALL

		-- RUOLI-UO ACCESSI
		SELECT DISTINCT
			RU.ID AS IdRuolo,
			RU.Codice AS CodiceRuolo,
			RU.Descrizione AS DescrizioneRuolo,
			AUO.Codice AS CodiceAccesso,
			AUO.Descrizione + ' per l''unità operativa ' + UO.Descrizione + ' di ' + UO.CodiceAzienda

		FROM organigramma.Ruoli AS RU

			LEFT JOIN organigramma.RuoliUnitaOperative RUO
				ON RUO.IdRuolo = RU.ID
			INNER JOIN organigramma.RuoliUnitaOperativeAttributi RUOA 
				ON RUO.ID = RUOA.IdRuoliUnitaOperative
			INNER JOIN organigramma.Attributi AUO 
				ON AUO.Codice = RUOA.CodiceAttributo AND AUO.UsoPerUnitaOperativa = 1	
			INNER JOIN organigramma.UnitaOperative UO
				ON UO.ID = RUO.IdUnitaOperativa
		
		WHERE RU.Attivo = 1 AND UO.Attivo= 1 AND (RU.ID = @IdRuolo OR @IdRuolo IS NULL)


	--
	-- ASSOCIAZIONE RUOLO/I-UO
	--
	SELECT DISTINCT
		  RU.ID AS IdRuolo,
		  UO.CodiceAzienda,
		  RU.Codice AS CodiceRuolo,
		  RU.Descrizione AS DescrizioneRuolo,
		  UO.Codice AS CodiceUO,
		  UO.Descrizione AS DescrizioneUO,
		  RE.Codice AS Regime

	FROM organigramma.Ruoli AS RU
	
		INNER JOIN
			organigramma.RuoliUnitaOperative RUO ON RU.ID = RUO.IdRuolo
		INNER JOIN 
			organigramma.UnitaOperative UO ON RUO.IdUnitaOperativa = UO.ID

		LEFT JOIN
			organigramma.UnitaOperativeRegimi UOR ON UO.ID = UOR.IdUnitaOperativa
		LEFT JOIN
			organigramma.Regimi RE ON UOR.CodiceRegime = RE.Codice
				
	WHERE RU.Attivo = 1 AND UO.Attivo= 1 AND (RU.ID = @IdRuolo OR @IdRuolo IS NULL)


	--
	-- ASSOCIAZIONE RUOLO/I-SISTEMI
	--
	SELECT DISTINCT
		  RU.ID AS IdRuolo,
		  SI.CodiceAzienda,
		  RU.Codice AS CodiceRuolo,
		  RU.Descrizione AS DescrizioneRuolo,
		  SI.ID AS IdSistema,
		  SI.Codice AS CodiceSistema

	FROM organigramma.Ruoli AS RU

		INNER JOIN
			organigramma.RuoliSistemi RSI ON RU.ID = RSI.IdRuolo
		INNER JOIN 
			organigramma.Sistemi SI ON RSI.IdSistema = SI.ID
	
	WHERE RU.Attivo = 1 AND SI.Attivo = 1 AND (RU.ID = @IdRuolo OR @IdRuolo IS NULL)

END