-- =============================================
-- Author:      Stefano P.
-- Create date: 2014-10
-- Description: Inserisce una riga di dbo.Oscuramenti
-- Modify date: 2015-02-04 Stefano: aggiunti 2 campi
-- Modify date: 2015-04-30 Stefano: aggiunto campo Titolo
-- Modify date: 2015-06-17 Stefano: aggiunti parametri @Parola, @IdEsternoReferto, @Utente
-- Modify date: 2016-10-12 Stefano: aggiunti parametri @ApplicaDWH, @ApplicaSole
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentiInserisce]
(
 @Titolo varchar(50),
 @Note varchar(1024),
 @AziendaErogante varchar(16),
 @SistemaErogante varchar(16),
 @NumeroNosologico varchar(64),
 @RepartoRichiedenteCodice varchar(16),
 @NumeroPrenotazione varchar(32),
 @NumeroReferto varchar(16),
 @IdOrderEntry varchar(64), 
 @RepartoErogante varchar(64),
 @StrutturaEroganteCodice varchar(64),
 @TipoOscuramento TINYINT,
 @Parola VARCHAR(64) = NULL,
 @IdEsternoReferto VARCHAR(64) = NULL,
 @Utente VARCHAR(128) = NULL,
 @ApplicaDWH BIT = 1,
 @ApplicaSole BIT = 1
)
AS
BEGIN
  SET NOCOUNT OFF

	IF @Utente IS NULL SET @Utente = SUSER_SNAME()
	
    INSERT INTO dbo.Oscuramenti
     (
	  TipoOscuramento,      
      Titolo,    
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
	  Parola,
	  IdEsternoReferto,
	  UtenteInserimento,
	  UtenteModifica,
	  ApplicaDWH, 
	  ApplicaSole
     )
    OUTPUT 
      INSERTED.Id,
      INSERTED.TipoOscuramento,
      INSERTED.Titolo,
      INSERTED.CodiceOscuramento,
      INSERTED.AziendaErogante,
      INSERTED.SistemaErogante,
      INSERTED.NumeroNosologico,
      INSERTED.RepartoRichiedenteCodice,
      INSERTED.NumeroPrenotazione,
      INSERTED.NumeroReferto,
      INSERTED.IdOrderEntry,
      INSERTED.Note,
      INSERTED.RepartoErogante,
      INSERTED.StrutturaEroganteCodice,
      INSERTED.Parola,
      INSERTED.IdEsternoReferto,
	  INSERTED.ApplicaDWH, 
	  INSERTED.ApplicaSole
    VALUES
     (    
      @TipoOscuramento,  
      NULLIF(@Titolo, ''),
      NULLIF(@AziendaErogante, ''),
      NULLIF(@SistemaErogante, ''),
      NULLIF(@NumeroNosologico, ''),
      NULLIF(@RepartoRichiedenteCodice, ''),
      NULLIF(@NumeroPrenotazione, ''),
      NULLIF(@NumeroReferto, ''),
      NULLIF(@IdOrderEntry, ''),
      NULLIF(@Note, ''),
      NULLIF(@RepartoErogante,''),
	  NULLIF(@StrutturaEroganteCodice,''),
	  NULLIF(@Parola,''),
	  NULLIF(@IdEsternoReferto,''),
	  @Utente,
	  @Utente,
	  @ApplicaDWH, 
	  @ApplicaSole
     )
   
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentiInserisce] TO [ExecuteFrontEnd]
    AS [dbo];

