

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-06
-- Modify date: 2015-04-10 SANDRO: aggiunti anche Sistemi e UnitaOperative
-- Modify date: 2015-06-08 SANDRO: aggiunto ID e Codice del ruolo
-- Modify date: 2017-03-30 ETTORE: Aggiunto campi Note e Descrizione con CAST espliciti
-- Description:	Ritorna la lista degli Accessi (calcolati sugli attributi, sistemi e unita operative) di un ruolo
-- =============================================
CREATE FUNCTION [organigramma].[OttieneAccessiPerIdRuolo]
(
	@idRuolo uniqueidentifier
)
RETURNS @Result TABLE (IdAccesso UNIQUEIDENTIFIER NOT NULL
						, CodiceAccesso VARCHAR(128) NOT NULL
						, TipoAccesso INT NOT NULL
						, Note VARCHAR(128)
						, Descrizione VARCHAR(512)
					  ) 
AS
BEGIN
	INSERT INTO @Result

	-- Ruolo ID
	SELECT 
		@idRuolo AS ID,
		--'ROLE@' + 
		CONVERT(VARCHAR(64), @idRuolo) AS CodiceAccesso,
		0 as TipoAccesso,
		CAST(NULL AS VARCHAR(128)) AS Note,
		CAST((SELECT Descrizione FROM organigramma.Ruoli WHERE Id = @idRuolo) AS VARCHAR(512)) AS Descrizione
	UNION ALL

	SELECT 
		R.ID,
		R.Codice AS CodiceAccesso,
		0 as TipoAccesso,
		CAST(NULL AS VARCHAR(128)) AS Note,
		CAST(R.Descrizione AS VARCHAR(512)) AS Descrizione
	FROM organigramma.Ruoli R
	WHERE R.Id = @idRuolo

	UNION ALL

	-- Tutti gli attributi del ruolo
	SELECT 
		RA.ID,
		'ATTRIB@' + RA.CodiceAttributo AS CodiceAccesso,
		0 as TipoAccesso,
		CAST(RA.Note AS VARCHAR(128)) AS Note,
		CAST(A.Descrizione AS VARCHAR(512)) AS Descrizione
	FROM organigramma.RuoliAttributi RA
		INNER JOIN organigramma.Attributi A 
			ON A.Codice = RA .CodiceAttributo AND A.UsoPerRuolo = 1
	WHERE RA.IdRuolo = @idRuolo

	UNION ALL
	-- Tutti gli attributi dei sistemi del ruolo
	SELECT 
		RSA.ID,
		'SE@' + S.Codice + '@' + S.CodiceAzienda + '@' + RSA.CodiceAttributo AS CodiceAccesso,
		1 as TipoAccesso,
		CAST(RSA.Note AS VARCHAR(128)) AS Note,
		CAST(A.Descrizione + ' per il sistema ' + S.Descrizione + ' di ' + S.CodiceAzienda AS VARCHAR(512)) AS Descrizione
	FROM organigramma.RuoliSistemi RS
		INNER JOIN organigramma.RuoliSistemiAttributi RSA 
			ON RS.ID = RSA.IdRuoloSistema
		INNER JOIN organigramma.Attributi A 
			ON A.Codice = RSA.CodiceAttributo AND A.UsoPerSistemaErogante = 1
		INNER JOIN organigramma.Sistemi S
			ON S.ID = RS.IdSistema
	WHERE RS.IdRuolo = @idRuolo

	UNION ALL
	-- Tutti gli attributi delle UO del ruolo
	SELECT 
		RUOA.ID,
		'UO@' + UO.Codice + '@' + UO.CodiceAzienda + '@' + RUOA.CodiceAttributo AS CodiceAccesso,
		2 as TipoAccesso,
		CAST(RUOA.Note AS VARCHAR(128)) AS Note, 
		CAST(A.Descrizione + ' per l''unità operativa ' + UO.Descrizione + ' di ' + UO.CodiceAzienda AS VARCHAR(512)) AS Descrizione
	FROM organigramma.RuoliUnitaOperative RUO
		INNER JOIN organigramma.RuoliUnitaOperativeAttributi RUOA 
			ON RUO.ID = RUOA.IdRuoliUnitaOperative
		INNER JOIN organigramma.Attributi A 
			ON A.Codice = RUOA.CodiceAttributo AND A.UsoPerUnitaOperativa = 1	
		INNER JOIN organigramma.UnitaOperative UO
			ON UO.ID = RUO.IdUnitaOperativa
	WHERE RUO.IdRuolo = @idRuolo

	UNION ALL
	-- Tutti gli i sistemi del ruolo
	SELECT 
		RS.ID,
		'SE@' + S.Codice + '@' + S.CodiceAzienda AS CodiceAccesso,
		1 as TipoAccesso,
		CAST(NULL AS VARCHAR(128)) AS Note,
		CAST(S.Descrizione + ' ' + S.CodiceAzienda  AS VARCHAR(512)) AS Descrizione
	FROM organigramma.RuoliSistemi RS
		INNER JOIN organigramma.Sistemi S
			ON S.ID = RS.IdSistema
	WHERE RS.IdRuolo = @idRuolo

	UNION ALL
	-- Tutti le UO del ruolo
	SELECT 
		RUO.ID,
		'UO@' + UO.Codice + '@' + UO.CodiceAzienda AS CodiceAccesso,
		2 as TipoAccesso,
		CAST(NULL AS VARCHAR(128)) AS Note,
		CAST(UO.Descrizione + ' ' + UO.CodiceAzienda AS VARCHAR(512)) AS Descrizione
	FROM organigramma.RuoliUnitaOperative RUO
		INNER JOIN organigramma.UnitaOperative UO
			ON UO.ID = RUO.IdUnitaOperativa
	WHERE RUO.IdRuolo = @idRuolo
	
	ORDER BY TipoAccesso, CodiceAccesso

	RETURN 
END

