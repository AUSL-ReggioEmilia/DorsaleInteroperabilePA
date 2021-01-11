
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-05-12
-- Description:	Accesso al SAC - Catena delle fusioni tra pazienti
-- =============================================
CREATE VIEW [sac].[PazientiFusioni]
AS
	SELECT [IdPaziente] AS IdPazienti
		  ,[IdPazienteFuso]
	FROM [SAC_PazientiFusioni] WITH(NOLOCK)
	WHERE [Abilitato] = 1