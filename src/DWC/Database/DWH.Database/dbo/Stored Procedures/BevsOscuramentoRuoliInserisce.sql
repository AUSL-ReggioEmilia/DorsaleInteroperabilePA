

-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-06-03
-- Modify date: 
-- Description: Inserisce un'associazione Oscuramento->Ruolo (che può bypassarlo)
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentoRuoliInserisce]
(
 @IdOscuramento uniqueidentifier,
 @IdRuolo uniqueidentifier,
 @UtenteInserimento varchar(128)
)
AS
BEGIN
  SET NOCOUNT OFF

	IF NOT EXISTS
	(
		SELECT * 
		FROM dbo.OscuramentoRuoli
		WHERE IdOscuramento = @IdOscuramento
		  AND IdRuolo = @IdRuolo
	)
	BEGIN
		INSERT INTO dbo.OscuramentoRuoli
		  (
		  IdOscuramento,
		  IdRuolo,
		  DataInserimento,
		  UtenteInserimento
		  )
		 OUTPUT
		  INSERTED.IdOscuramento,
		  INSERTED.IdRuolo,
		  INSERTED.DataInserimento,
		  INSERTED.UtenteInserimento
		 VALUES
		  (
		  @IdOscuramento,
		  @IdRuolo,
		  GETUTCDATE(),
		  NULLIF(@UtenteInserimento, '')
		  )
	END

    RETURN 0

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentoRuoliInserisce] TO [ExecuteFrontEnd]
    AS [dbo];

