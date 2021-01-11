


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[EnnupleAccessi]
AS
SELECT e.[ID]
      ,e.[Descrizione]
      ,e.[Not]
      ,st.[Descrizione] AS [Stato]

	  ,R AS Legge
	  ,I AS Inserisce
	  ,S AS Inoltra

	  ,e.[IDGruppoUtenti]
      ,gu.[Descrizione] AS [GruppoUtenti]
	  
 	  ,e.[IDSistemaErogante] 
      ,se.[CodiceAzienda] + '-' + se.[Codice] AS [SistemaErogante]

	  ,e.[DataInserimento]
      ,e.[DataModifica]
      ,e.[UtenteInserimento]
      ,e.[UtenteModifica]

  FROM [dbo].[EnnupleAccessi] e WITH(NOLOCK)
	INNER JOIN [dbo].[EnnupleStati] st WITH(NOLOCK)
		ON e.[IDStato] = st.[ID]

	LEFT JOIN [dbo].[GruppiUtenti] gu WITH(NOLOCK)
		ON e.[IDGruppoUtenti] = gu.[ID]

	LEFT JOIN [dbo].[SistemiEstesa] se WITH(NOLOCK)
		ON e.[IDSistemaErogante] = se.[ID]
