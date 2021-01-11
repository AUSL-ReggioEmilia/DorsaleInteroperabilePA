
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2011-11-18, eliminato il campo P.IDParametroSpecifico
-- Modify date: 2014-02-17, eliminati campi data e ticket e aggiunto CodiceSinonimo
-- Modify sandro: 2015-11-04, Non ritorna righe doppie e controlla anche che non sia ''
-- Description:	Seleziona le prestazioni per ID , separati da virgola
--					che hanno il CodiceSinonimo
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniSelectByIDsAndCodiceSininimo]
	@IDs varchar(max)
AS
BEGIN
	SET NOCOUNT ON;
	
	------------------------------
	-- SPLIT
	------------------------------	
	DECLARE @Value varchar(50), @Pos int
	DECLARE @tmp TABLE (ID uniqueidentifier)

	SET @IDs = LTRIM(RTRIM(@IDs))+ ','
	SET @Pos = CHARINDEX(',', @IDs, 1)

	IF REPLACE(@IDs, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @Value = LTRIM(RTRIM(LEFT(@IDs, @Pos - 1)))
			
			IF @Value <> ''
			BEGIN
				INSERT INTO @tmp (ID) VALUES (@Value)
			END
			
			SET @IDs = RIGHT(@IDs, LEN(@IDs) - @Pos)
			SET @Pos = CHARINDEX(',', @IDs, 1)
		END
	END

	SELECT DISTINCT P.*		
	FROM CorePrestazioniSelect P
		INNER JOIN @tmp IDS ON P.ID = IDS.ID
	WHERE NOT NULLIF(P.CodiceSinonimo, '') IS NULL
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniSelectByIDsAndCodiceSininimo] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniSelectByIDsAndCodiceSininimo] TO [DataAccessWs]
    AS [dbo];

