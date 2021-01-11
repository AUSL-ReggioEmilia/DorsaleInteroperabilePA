
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[EnnuplePrestazioni]
AS
SELECT e.[ID]
      ,e.[Descrizione]
      ,e.[Not]
      ,st.[Descrizione] AS [Stato]

	  ,e.[IDGruppoUtenti]
      ,gu.[Descrizione] AS [GruppoUtenti]

	  ,e.[IDGruppoPrestazioni]
      ,gp.[Descrizione] AS [GruppoPrestazioni]

      ,e.[OrarioInizio]
      ,e.[OrarioFine]
      ,e.[Lunedi]
      ,e.[Martedi]
      ,e.[Mercoledi]
      ,e.[Giovedi]
      ,e.[Venerdi]
      ,e.[Sabato]
      ,e.[Domenica]


	  ,e.[IDUnitaOperativa] 
      ,uo.[CodiceAzienda] + '-' + uo.[Codice] AS [UnitaOperativa]

	  ,e.[IDSistemaRichiedente] 
      ,sr.[CodiceAzienda] + '-' + sr.[Codice] AS [SistemaRichiedente]

      ,e.[CodiceRegime]
      ,e.[CodicePriorita]

	  ,e.[DataInserimento]
      ,e.[DataModifica]
      ,e.[UtenteInserimento]
      ,e.[UtenteModifica]

  FROM [dbo].[Ennuple] e WITH(NOLOCK)
	INNER JOIN [dbo].[EnnupleStati] st WITH(NOLOCK)
		ON e.[IDStato] = st.[ID]

	LEFT JOIN [dbo].[GruppiUtenti] gu WITH(NOLOCK)
		ON e.[IDGruppoUtenti] = gu.[ID]

	LEFT JOIN [dbo].[GruppiPrestazioni] gp WITH(NOLOCK)
		ON e.[IDGruppoPrestazioni] = gp.[ID]

	LEFT JOIN [dbo].[UnitaOperativeEstesa] uo WITH(NOLOCK)
		ON e.[IDUnitaOperativa] = uo.[ID]

	LEFT JOIN [dbo].[SistemiEstesa] sr WITH(NOLOCK)
		ON e.[IDSistemaRichiedente] = sr.[ID]


