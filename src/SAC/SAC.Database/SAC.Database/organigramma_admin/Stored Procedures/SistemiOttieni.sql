
CREATE PROC [organigramma_admin].[SistemiOttieni]
(
 @ID uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
      [ID],
      [Codice],
      [CodiceAzienda],
      [Descrizione],
      [Erogante],
      [Richiedente],
      [Attivo],
      [DataInserimento],
      [DataModifica],
      [UtenteInserimento],
      [UtenteModifica]
  FROM  [organigramma].[Sistemi]
  WHERE [ID] = @ID

END
