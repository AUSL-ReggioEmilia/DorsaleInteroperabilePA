
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2011-11-18, eliminato il campo P.IDParametroSpecifico
-- Modify date: 2014-02-17, eliminati campi data e ticket e aggiunto CodiceSinonimo
-- Description:	Seleziona le prestazioni per ID , separati da virgola
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniSelectByIDs]
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

	SELECT P.*		
	FROM CorePrestazioniSelect P
		INNER JOIN @tmp IDS ON P.ID = IDS.ID
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniSelectByIDs] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniSelectByIDs] TO [DataAccessWs]
    AS [dbo];

