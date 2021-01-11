

CREATE VIEW [organigramma_admin].[RuoliUnitaOperativeLista]
AS
    SELECT [RuoliUnitaOperative].IdRuolo
		,[Ruoli].[Descrizione] AS [DescrizioneRuolo]
		,[Ruoli].[Attivo] AS [AttivoRuolo]
		,[RuoliUnitaOperative].[IdUnitaOperativa]
		,[UnitaOperative].[Codice] + '@' + [UnitaOperative].[CodiceAzienda] AS [CodiceUnitaOperativa]
		,ISNULL([UnitaOperative].[Descrizione], [UnitaOperative].[Codice]) + ' @ '
			 + ISNULL([Aziende].[Descrizione], [UnitaOperative].[CodiceAzienda]) AS [DescrizioneUnitaOperativa]
		
    FROM [organigramma].[RuoliUnitaOperative] INNER JOIN [organigramma].[UnitaOperative]
			ON [RuoliUnitaOperative].[IdUnitaOperativa] = [UnitaOperative].[ID]
			
				INNER JOIN [organigramma].[Aziende]
			ON [UnitaOperative].[CodiceAzienda] = [Aziende].[Codice]

				INNER JOIN [organigramma].[Ruoli]
			ON [RuoliUnitaOperative].IdRuolo = [Ruoli].[ID]
