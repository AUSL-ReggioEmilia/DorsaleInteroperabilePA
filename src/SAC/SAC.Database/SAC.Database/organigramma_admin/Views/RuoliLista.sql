


CREATE VIEW [organigramma_admin].[RuoliLista]
AS
	SELECT [ID]
		,[Descrizione]
		,[Attivo]
		,[organigramma_admin].[ConcatenaRuoliSistemi]([Ruoli].[ID]) AS Sistemi
		,[organigramma_admin].[ConcatenaRuoliUnitaOperative]([Ruoli].[ID]) AS UnitaOperative

	FROM [organigramma].[Ruoli]
