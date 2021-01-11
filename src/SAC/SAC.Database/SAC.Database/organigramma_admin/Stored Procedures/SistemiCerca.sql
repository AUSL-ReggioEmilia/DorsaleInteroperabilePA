
-- =============================================
-- Author:		--
-- Create date: --
-- Description: Ottiene la lista dei Sistemi.
-- Modify Date: SimoneBitti - 2017-06-12: Aggiunto filtro @Attivo.
-- =============================================

CREATE PROC [organigramma_admin].[SistemiCerca]
(
 @Codice varchar(16) = NULL,
 @Descrizione varchar(128) = NULL,
 @Erogante bit = NULL,
 @Richiedente bit = NULL,
 @CodiceAzienda varchar(16),
 @Top INT = NULL,
 @Attivo BIT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  SELECT TOP (ISNULL(@Top, 1000)) 
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
  WHERE 
      (Codice LIKE '%' + @Codice + '%' OR @Codice IS NULL) AND 
      (Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) AND 
      (Erogante = @Erogante OR @Erogante IS NULL) AND 
      (Richiedente = @Richiedente OR @Richiedente IS NULL) AND 
      (CodiceAzienda = @CodiceAzienda OR @CodiceAzienda IS NULL) AND
	  (Attivo = @Attivo OR @Attivo IS NULL)
END
