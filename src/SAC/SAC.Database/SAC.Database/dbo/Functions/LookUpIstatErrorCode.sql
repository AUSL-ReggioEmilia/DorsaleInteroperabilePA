-- =============================================
-- Author:		Ettore
-- Create date: 2014-03-25
-- Description:	restituisce il messaggio di errore di incoerenza Istat
-- =============================================
CREATE FUNCTION [dbo].[LookUpIstatErrorCode]
(
	@ErrorCode INTEGER
)
RETURNS VARCHAR(128)
AS
BEGIN
	
	DECLARE @ErroMessage AS VARCHAR(128)

	IF @ErrorCode = 5000 --comune nascita non valido
	BEGIN
		SET @ErroMessage = 'Errore di incoerenza istat su comune nascita.'
	END
	ELSE
	IF @ErrorCode = 5001 --comune residenza non valido
	BEGIN
		SET @ErroMessage = 'Errore di incoerenza istat su comune residenza.' 
	END
	ELSE
	IF @ErrorCode = 5002 --comune domicilio non valido
	BEGIN
		SET @ErroMessage = 'Errore di incoerenza istat su comune domicilio.'
	END
	ELSE
	IF @ErrorCode = 5003 --comune recapito non valido (per ora non usato)
	BEGIN
		SET @ErroMessage = 'Errore di incoerenza istat su comune domicilio.'
	END
	--
	-- Restituisco il codice di errore
	--
	RETURN @ErroMessage 

END
