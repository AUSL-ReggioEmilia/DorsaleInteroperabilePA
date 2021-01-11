
-- ===============================================================================================================
-- Author:		Kyrylo
-- Create date: 2020-11-19
--
-- Description:	Restitusce i record da [OggettiActiveDirectory] filtrati con i parametri
-- ===============================================================================================================
CREATE PROC [organigramma_admin].[OggettiActiveDirectoryCerca2]
(
 @Utente varchar(128) = NULL,
 @Tipo varchar(32) = NULL,
 @Descrizione varchar(256) = NULL,
 @MembroConRuolo bit = 1,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  SELECT TOP (ISNULL(@Top, 1000)) 
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
  WHERE 
      (Utente LIKE '%' + @Utente + '%' OR @Utente IS NULL) AND 
      (Tipo = @Tipo OR @Tipo IS NULL) AND 
      (Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) 
      AND
      ( @MembroConRuolo = 0
        OR --FILTRO SUI SOLI MEMBRI CON ALMENO UN RUOLO ASSEGNATO
		   --O PER APPARTENENZA AD UN GRUPPO CON DEI RUOLI ASSEGNATI
		( @MembroConRuolo = 1
		  AND 
			  (
				EXISTS( 
						--VERIFICO L'APPARTENENEZA DIRETTA DEL MEMBRO AD UN RUOLO
						SELECT RUO.IdUtente
		   				FROM organigramma.RuoliOggettiActiveDirectory RUO 
						WHERE RUO.IDUtente = OggettiActiveDirectory.ID)
				OR

				EXISTS( 
						--VERIFICO L'APPARTENENEZA DEL MEMBRO (SOLO SE UTENTE) AD UN RUOLO TRAMITE 
						--L'APPARTENENZA AD UN GRUPPO CON DEI RUOLI ASSEGNATI
						SELECT UG.Id
		   				FROM organigramma.OggettiActiveDirectoryUtentiGruppi UG 
						JOIN [organigramma].[RuoliOggettiActiveDirectory] AS RUO 
							ON RUO.IdUtente = UG.IdGruppo
						WHERE UG.IDUtente = OggettiActiveDirectory.ID AND OggettiActiveDirectory.Tipo = 'Utente')
			  )
		 )
       )
      
END