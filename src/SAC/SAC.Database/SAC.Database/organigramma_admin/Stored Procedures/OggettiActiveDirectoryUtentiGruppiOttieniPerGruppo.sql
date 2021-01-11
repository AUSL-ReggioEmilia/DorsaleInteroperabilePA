CREATE PROC [organigramma_admin].[OggettiActiveDirectoryUtentiGruppiOttieniPerGruppo]
(
 @IdGruppo uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

-- RESTITUSCE TUTTI I MEMBRI DEL GRUPPO PASSATO
	
  SELECT 
      UG.Id, 
      UG.IdUtente,
      UG.IdGruppo,
      AD.Utente,
      AD.Descrizione,
      AD.Tipo,      
      UG.DataInserimento,
      UG.DataModifica,
      UG.UtenteInserimento,
      UG.UtenteModifica
  FROM  
	organigramma.OggettiActiveDirectoryUtentiGruppi UG
  INNER JOIN
	organigramma.OggettiActiveDirectory AD ON UG.IdUtente = AD.Id
  
  WHERE UG.IdGruppo = @IdGruppo

END
