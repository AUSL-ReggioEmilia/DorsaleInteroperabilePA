
CREATE PROCEDURE dbo.UiGruppiUtentiPerUtente

@IDUtente AS UNIQUEIDENTIFIER

AS
BEGIN
SET NOCOUNT ON

  SELECT  
	GU.ID
   ,GU.Descrizione
  
  FROM
	dbo.GruppiUtenti AS GU
  INNER JOIN dbo.UtentiGruppiUtenti AS UGU 
	ON  GU.ID = UGU.IDGruppoUtenti
	AND	UGU.IDUtente = @IDUtente
  
  ORDER BY GU.Descrizione


END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiGruppiUtentiPerUtente] TO [DataAccessUi]
    AS [dbo];

