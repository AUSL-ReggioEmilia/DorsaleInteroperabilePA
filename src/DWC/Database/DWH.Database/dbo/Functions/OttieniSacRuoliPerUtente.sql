
-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2016-09-01
-- Description:	Restituisce la lista dei ruoli associati ad un utente letta dal SAC
-- =============================================
CREATE FUNCTION [dbo].[OttieniSacRuoliPerUtente]
(
	@Utente VARCHAR(128)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT RuoloCodice
	  FROM [dbo].[SAC_RuoliUtenti]
	  WHERE Utente = @Utente 
)