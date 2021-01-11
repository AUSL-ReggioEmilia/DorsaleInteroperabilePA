-- =============================================
-- Author:		...
-- Create date: ...
-- Modify sate: 2016-05-26 Rimosso controllo accesso di lettura
-- Description:	Ritorna la lista dele fusioni
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputFusioniByIdPaziente]
	@IdPaziente uniqueidentifier

AS
BEGIN

DECLARE @Identity AS varchar(64)

	SET NOCOUNT ON;

	IF @IdPaziente IS NULL
	BEGIN
		RAISERROR('Il parametro IdPaziente non può essere NULL!', 16, 1)
		RETURN
	END

	SELECT
		  IdPaziente
		, IdPazienteFuso
		, ProgressivoFusione
		, Abilitato
		, DataInserimento
		
	FROM
		dbo.PazientiFusioniSpResult
		
	WHERE     
		IdPaziente = @IdPaziente OR IdPazienteFuso = @IdPaziente
		
	ORDER BY
		Abilitato DESC, ProgressivoFusione
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputFusioniByIdPaziente] TO [DataAccessSql]
    AS [dbo];

