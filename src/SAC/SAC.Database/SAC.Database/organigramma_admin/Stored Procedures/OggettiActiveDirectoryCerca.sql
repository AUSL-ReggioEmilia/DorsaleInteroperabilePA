-- =============================================
-- Author:      Stefano P.
-- Create date: 2014
-- Description: Ricerca sulla tabella [organigramma].[OggettiActiveDirectory]
-- Modify date: 2015-07-14 Stefano: corretto bug quando @MembroConRuolo=1
-- =============================================
CREATE PROC [organigramma_admin].[OggettiActiveDirectoryCerca]
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
		( @MembroConRuolo = 1
		  AND EXISTS( SELECT ID
		   		      FROM organigramma.RuoliOggettiActiveDirectory RUO 
				      WHERE RUO.IDUtente = OggettiActiveDirectory.ID  )
		)
      )
      
END
