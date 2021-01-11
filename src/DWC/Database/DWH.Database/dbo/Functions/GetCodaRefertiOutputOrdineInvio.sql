-- =============================================
-- Author:		Sandro
-- Create date: 2012-02-02
-- Create date: 2019-05-20 Legge dati di priorità dalla tabella [dbo].[SistemiEroganti]
-- Description:	Per compatibilità non valuta Azienda Erogante ma valuta il valore minore del sistema
--				Necessario una modifica per aggiungere un parametro
--
-- =============================================
CREATE FUNCTION [dbo].[GetCodaRefertiOutputOrdineInvio]
(
 @SistemaErogante VARCHAR(16)
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @Ret SMALLINT = 5
	SELECT @Ret = ISNULL(MIN([PrioritaInvioReferti]), 5)
		FROM [dbo].[SistemiEroganti]
		WHERE [SistemaErogante] = @SistemaErogante
	--
	-- Restituisco
	--
	RETURN @Ret 
END
