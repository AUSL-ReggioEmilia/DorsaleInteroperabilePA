CREATE PROC [organigramma_admin].[OggettiActiveDirectoryUtentiGruppiOttieniPerUtente]
(
  @IdUtente uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

-- RESTITUISCE TUTTI I GRUPPI AI QUALI APPARTIENE IL MEMBRO PASSATO

  SELECT 
      UG.Id, 
      UG.IdUtente,
      UG.IdGruppo,
      GRU.Utente,
      GRU.Descrizione,
      GRU.Tipo,           
      UG.DataInserimento,
      UG.DataModifica,
      UG.UtenteInserimento,
      UG.UtenteModifica
  FROM  
	organigramma.OggettiActiveDirectoryUtentiGruppi UG
  INNER JOIN
	organigramma.OggettiActiveDirectory UTE ON UG.IdUtente = UTE.Id
  INNER JOIN
	organigramma.OggettiActiveDirectory GRU ON UG.IdGruppo = GRU.Id
  
  WHERE UG.IdUtente = @IdUtente

END

