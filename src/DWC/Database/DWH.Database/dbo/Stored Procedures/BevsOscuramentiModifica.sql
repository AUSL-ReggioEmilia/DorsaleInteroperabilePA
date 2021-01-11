
-- =============================================
-- Author:      Stefano P.
-- Create date: 2014-10
-- Description: Aggiorna una riga di dbo.Oscuramenti
-- Modify date: 2015-02-04 Stefano: aggiunti 2 campi
-- Modify date: 2015-04-30 Stefano: aggiunti campo Titolo
-- Modify date: 2015-06-17 Stefano: aggiunti parametri @Parola, @IdEsternoReferto, @Utente
-- Modify date: 2016-10-12 Stefano: aggiunti parametri @ApplicaDWH, @ApplicaSole
-- Modify date: 2017-11-07 SimoneB: aggiunti parametri @Stato
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentiModifica]
(
 @Id uniqueidentifier,
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
 @ApplicaSole BIT = 1,
 @Stato VARCHAR(16)
)
AS
BEGIN
		
	SET NOCOUNT OFF

	IF @Utente IS NULL SET @Utente = SUSER_SNAME()

	--
	-- ELIMINO LE EVENTUALI ASSOCIAZIONI CON I RUOLI CHE POSSONO BYPASSARE L'OSCURAMENTO
	-- SE NEL SALVATAGGIO VIENE VARIATO IL TIPO DI OSCURAMENTO
	--
	DELETE dbo.OscuramentoRuoli
	WHERE IdOscuramento = @Id
	 AND EXISTS ( SELECT 1 FROM dbo.Oscuramenti
				  WHERE Id = @Id
				    AND TipoOscuramento <> @TipoOscuramento )

    UPDATE dbo.Oscuramenti
     SET   
      Titolo = NULLIF(@Titolo, ''),
      AziendaErogante = NULLIF(@AziendaErogante, ''),
      SistemaErogante = NULLIF(@SistemaErogante, ''),
      NumeroNosologico = NULLIF(@NumeroNosologico, ''),
      RepartoRichiedenteCodice = NULLIF(@RepartoRichiedenteCodice, ''),
      NumeroPrenotazione = NULLIF(@NumeroPrenotazione, ''),
      NumeroReferto = NULLIF(@NumeroReferto, ''),
      IdOrderEntry = NULLIF(@IdOrderEntry, ''),
      Note = NULLIF(@Note, ''),
      RepartoErogante = NULLIF(@RepartoErogante,''),
	  StrutturaEroganteCodice = NULLIF(@StrutturaEroganteCodice,''), 
	  TipoOscuramento = @TipoOscuramento,
	  Parola = NULLIF(@Parola, ''),
	  IdEsternoReferto = NULLIF(@IdEsternoReferto,''),
      DataModifica = GETUTCDATE(),
      UtenteModifica = @Utente,
	  ApplicaDWH = @ApplicaDWH,
	  ApplicaSole = @ApplicaSole,
	  Stato = @Stato
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
	  INSERTED.ApplicaSole,
	  INSERTED.Stato
	 WHERE Id = @Id

   
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentiModifica] TO [ExecuteFrontEnd]
    AS [dbo];

