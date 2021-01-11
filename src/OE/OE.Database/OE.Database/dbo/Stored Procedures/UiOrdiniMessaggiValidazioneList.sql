
CREATE PROCEDURE [dbo].[UiOrdiniMessaggiValidazioneList]

 @IdOrderEntry as uniqueidentifier 

AS
BEGIN
SET NOCOUNT ON

SELECT Validazione 
FROM OrdiniTestate 
WHERE ID = @IdOrderEntry

SET NOCOUNT OFF
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniMessaggiValidazioneList] TO [DataAccessUi]
    AS [dbo];

