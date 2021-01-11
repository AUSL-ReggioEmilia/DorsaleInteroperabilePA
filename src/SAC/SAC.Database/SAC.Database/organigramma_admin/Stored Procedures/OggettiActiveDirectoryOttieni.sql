CREATE PROC [organigramma_admin].[OggettiActiveDirectoryOttieni]
(
 @Id uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
      [Id],
      [Utente],
      [Tipo],
      [Descrizione],
      [Cognome],
      [Nome],
      [CodiceFiscale],
      [Matricola],
      [Email],  
      [Attivo],
      [DataInserimento],
      [DataModifica],
      [UtenteInserimento],
      [UtenteModifica]
  FROM  [organigramma].[OggettiActiveDirectory]
  WHERE [Id] = @Id

END
