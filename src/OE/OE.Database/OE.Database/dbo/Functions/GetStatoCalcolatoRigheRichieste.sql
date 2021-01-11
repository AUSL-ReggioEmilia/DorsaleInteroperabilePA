-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-10-19
-- Description:	Calcolo dello stato delle righe richieste
-- =============================================

CREATE FUNCTION [dbo].[GetStatoCalcolatoRigheRichieste]
(
 @OperazioneOrderEntry VARCHAR(16)
,@StatoRigaRichesta VARCHAR(16)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
DECLARE @returnValue AS VARCHAR(MAX) = ''

	IF @OperazioneOrderEntry = 'HD'
	BEGIN
		--Inserita
		IF @StatoRigaRichesta = 'CA'		SET @returnValue = 'CANCELLATO'
		ELSE IF @StatoRigaRichesta = 'MD'	SET @returnValue = 'MODIFICATO'
		ELSE IF @StatoRigaRichesta = 'IS'	SET @returnValue = 'INSERITO'
		ELSE								SET @returnValue = @StatoRigaRichesta

	END	ELSE BEGIN
		--Inoltrata

		IF @StatoRigaRichesta = 'CA'		SET @returnValue = 'CANCELLATO'
		ELSE IF @StatoRigaRichesta = 'MD'	SET @returnValue = 'MODIFICATO'
		ELSE IF @StatoRigaRichesta = 'IS'	SET @returnValue = 'INOLTRATO'
		ELSE								SET @returnValue = @StatoRigaRichesta
	END

	RETURN @returnValue
END