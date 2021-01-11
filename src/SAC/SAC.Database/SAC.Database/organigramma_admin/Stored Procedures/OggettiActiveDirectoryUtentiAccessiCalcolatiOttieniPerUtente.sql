CREATE PROC organigramma_admin.OggettiActiveDirectoryUtentiAccessiCalcolatiOttieniPerUtente
(
 @IdUtente uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
      ACC.Id,
      ACC.Accesso,
      ACC.DataInserimento,
      ACC.DataModifica,
      ACC.UtenteInserimento,
      ACC.UtenteModifica
  FROM  
	organigramma.OggettiActiveDirectoryUtentiAccessiCalcolati ACC
  WHERE 
	ACC.IdUtente = @IdUtente

END
