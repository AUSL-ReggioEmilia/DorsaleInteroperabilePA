

-- =============================================
-- Author:      Stefano P.
-- Create date: 2014-10
-- Description: Ottiene una riga di dbo.Oscuramenti
-- Modify date: 2015-02-04 Stefano: aggiunti 2 campi
-- Modify date: 2015-04-30 Stefano: aggiunto campo Titolo
-- Modify date: 2015-06-17 Stefano: aggiunti campi Parola, IdEsternoReferto
-- Modify date: 2016-10-12 Stefano: aggiunti campi ApplicaDWH, ApplicaSole
-- Modify date: 2017-11-08 SimoneB: Restituisco anche IdCorrelazione
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentiOttieni]
(
 @Id uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
      Id,
      CodiceOscuramento,
      AziendaErogante,
      SistemaErogante,
      NumeroNosologico,
      RepartoRichiedenteCodice,
      NumeroPrenotazione,
      NumeroReferto,
      IdOrderEntry,
      Note,
      RepartoErogante,
      StrutturaEroganteCodice,
      TipoOscuramento,
      Titolo,
      Parola,
      IdEsternoReferto,
      ApplicaDWH, 
	  ApplicaSole,
	  Stato,
	  IdCorrelazione
  FROM  dbo.Oscuramenti
  WHERE Id = @Id

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentiOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

