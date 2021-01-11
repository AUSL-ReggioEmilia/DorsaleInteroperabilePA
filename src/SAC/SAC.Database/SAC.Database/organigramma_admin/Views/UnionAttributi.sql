
-- =============================================
-- Author:      Stefano P.
-- Create date: 2014
-- Description: Restituisce la sommatoria degli attributi di RuoliAttributi + RuoliSistemi + RuoliUnitaOperative
-- Modify date: 2015-04-08 Stefano: modifcato campo Descrizione
-- =============================================

CREATE VIEW [organigramma_admin].[UnionAttributi]
AS
	SELECT 
		RA.ID,
		RA.IdRuolo,
		'ATTRIB@' + A.Codice AS CodiceAttributo,
		RA.Note,
		A.Descrizione,
		0 as TipoAttributo
	FROM organigramma.RuoliAttributi RA
	INNER JOIN organigramma.Attributi A 
	  ON A.Codice = RA.CodiceAttributo AND A.UsoPerRuolo = 1

	UNION ALL

	SELECT 
		RSA.ID,
		RS.IdRuolo,
		'SE@'  + S.Codice + '@' + S.CodiceAzienda + '@' + RSA.CodiceAttributo AS CodiceAttributo,
		RSA.Note,
		A.Descrizione + ' per il sistema ' + S.Descrizione + ' di ' + S.CodiceAzienda,
		1 as TipoAttributo
	FROM organigramma.RuoliSistemi RS
	INNER JOIN organigramma.RuoliSistemiAttributi RSA 
	  ON RS.ID = RSA.IdRuoloSistema
	INNER JOIN organigramma.Attributi A 
	  ON A.Codice = RSA.CodiceAttributo AND A.UsoPerSistemaErogante = 1
	INNER JOIN organigramma.Sistemi S
	  ON S.ID = RS.IdSistema
	
	UNION ALL

	SELECT 
		RUOA.ID,
		RUO.IdRuolo,
		'UO@' + UO.Codice + '@' + UO.CodiceAzienda + '@' + RUOA.CodiceAttributo AS CodiceAttributo,
		RUOA.Note,
		A.Descrizione + ' per l''unità operativa ' + UO.Descrizione + ' di ' + UO.CodiceAzienda,
		2 as TipoAttributo
	FROM organigramma.RuoliUnitaOperative RUO
	INNER JOIN organigramma.RuoliUnitaOperativeAttributi RUOA 
	  ON RUO.ID = RUOA.IdRuoliUnitaOperative
	INNER JOIN organigramma.Attributi A 
	  ON A.Codice = RUOA.CodiceAttributo AND A.UsoPerUnitaOperativa = 1	
	INNER JOIN organigramma.UnitaOperative UO
	  ON UO.ID = RUO.IdUnitaOperativa
	  




