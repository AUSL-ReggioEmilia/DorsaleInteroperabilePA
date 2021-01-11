


CREATE PROCEDURE [dbo].[UiGruppiPrestazioniUpdate1]

@ID as uniqueidentifier,
@Descrizione as varchar(128),
@Preferiti as bit,
@Note AS VARCHAR(1024)

AS
BEGIN
SET NOCOUNT ON

UPDATE [dbo].[GruppiPrestazioni]
 SET 
       [Descrizione] = @Descrizione,
       [Preferiti] = @Preferiti
	   ,[Note] = @Note
 WHERE [ID] = @ID

SELECT * FROM [dbo].[GruppiPrestazioni]

SET NOCOUNT OFF
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiGruppiPrestazioniUpdate1] TO [DataAccessUi]
    AS [dbo];

