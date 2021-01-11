
-- =============================================
-- Author:		Sandro
-- Create date: 2019-05-20
--
-- Description:	 Legge dati di priorità dalla tabella [dbo].[SistemiEroganti]
--
-- =============================================
CREATE FUNCTION [dbo].[GetCodaEventiOutputOrdineInvio]
(
 @AziendaErogante VARCHAR(16)
,@SistemaErogante VARCHAR(16)
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @Ret SMALLINT = 5
	SELECT @Ret = ISNULL([PrioritaInvioEventi], 5)
		FROM [dbo].[SistemiEroganti]
		WHERE [AziendaErogante] = @AziendaErogante
			AND [SistemaErogante] = @SistemaErogante
	--
	-- Restituisco
	--
	RETURN @Ret 
END