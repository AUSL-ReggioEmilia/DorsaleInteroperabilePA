


CREATE PROCEDURE [dbo].[_Schedule_AttivitaFrequente] 
AS
BEGIN

	-- Merge dei pazienti con limite massimo di fusioni sui pazienti ultima ora
	EXEC dbo.PazientiBatchMerge 100, 60

	-------------------------------------------------------------------- 
	-- Pulisce dati TESSERA
	
	UPDATE  [SAC].[dbo].[Pazienti]
	SET [Tessera] = REPLACE([Tessera], CHAR(10), '')
	WHERE [Tessera] LIKE '%' + CHAR(10) + '%'

	UPDATE  [SAC].[dbo].[Pazienti]
	SET [Tessera] = REPLACE([Tessera], CHAR(13), '')
	WHERE [Tessera] LIKE '%' + CHAR(13) + '%'

	UPDATE  [SAC].[dbo].[Pazienti]
	SET [Tessera] = NULL
	WHERE RTRIM([Tessera]) = ''

	-------------------------------------------------------------------- 
	-- Pulisce dati CF

	UPDATE  [SAC].[dbo].[Pazienti]
	SET [CodiceFiscale] = REPLACE([CodiceFiscale], CHAR(10), '')
	WHERE [CodiceFiscale] LIKE '%' + CHAR(10) + '%'

	UPDATE  [SAC].[dbo].[Pazienti]
	SET [CodiceFiscale] = REPLACE([CodiceFiscale], CHAR(13), '')
	WHERE [CodiceFiscale] LIKE '%' + CHAR(13) + '%'

	UPDATE  [SAC].[dbo].[Pazienti]
	SET [CodiceFiscale] = NULL
	WHERE [CodiceFiscale] = ''

	-------------------------------------------------------------------- 
END



