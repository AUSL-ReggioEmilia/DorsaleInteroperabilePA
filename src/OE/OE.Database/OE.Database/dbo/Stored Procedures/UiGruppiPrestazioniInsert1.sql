

-- =============================================
-- Author:      
-- Create date: 
-- Description: Inserimento Gruppo Prestazioni
-- Modify date: 2015-07-17 Stefano P: ora ritorna il record appena inserito
-- =============================================
CREATE PROCEDURE [dbo].[UiGruppiPrestazioniInsert1]

@Descrizione as varchar(128),
@Preferiti as bit,
@Note AS VARCHAR(1024) = NULL

AS
BEGIN

	DECLARE @newId AS UNIQUEIDENTIFIER = NEWID()

	INSERT INTO [dbo].[GruppiPrestazioni]
			   ([ID]
			   ,[Descrizione]
			   ,Preferiti
			   ,Note
			   )
		 VALUES
			   (@newId
			   ,@Descrizione
			   ,@Preferiti
			   ,@Note)

	SELECT * FROM [dbo].[GruppiPrestazioni] WHERE ID = @newId

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiGruppiPrestazioniInsert1] TO [DataAccessUi]
    AS [dbo];

