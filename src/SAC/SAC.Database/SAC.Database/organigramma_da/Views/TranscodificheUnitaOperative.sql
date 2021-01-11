

-- ================================================
-- Author:		Alessandro Nostini
-- Create date: 2014-07-11
-- Description:	Lista delle transcodifica delle UO
-- ================================================
CREATE VIEW [organigramma_da].[TranscodificheUnitaOperative]
AS
	SELECT 
		 UO.CodiceAzienda AS UnitaOperativaAzienda
		,UO.Codice AS UnitaOperativaCodice
		,UO.Descrizione AS UnitaOperativaDescrizione
		,S.CodiceAzienda AS SistemaAzienda
		,S.Codice AS SistemaCodice	
		,UOS.CodiceAzienda AS TransAzienda
		,UOS.Codice AS TransCodice
		,UOS.Descrizione AS TransDescrizione

	FROM [organigramma].[UnitaOperativeSistemi] UOS
		INNER JOIN [organigramma].[UnitaOperative] UO
			ON UO.ID = UOS.IdUnitaOperativa
				AND UO.Attivo = 1
		INNER JOIN [organigramma].[Sistemi] S
			ON S.ID = UOS.IdSistema
				AND S.Attivo = 1
