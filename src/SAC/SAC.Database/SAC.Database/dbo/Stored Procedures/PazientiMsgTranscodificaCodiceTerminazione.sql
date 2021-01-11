-- =============================================
-- Author:		ETTORE
-- Create date: 2019-01-15
-- Description:	Transcodifica dei codici terminazione
-- =============================================
CREATE PROCEDURE dbo.PazientiMsgTranscodificaCodiceTerminazione
(
	@Utente AS varchar(64)
	, @CodiceEsterno AS varchar(8)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Provenienza AS VARCHAR(16)
	SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante [PazientiMsgTranscodificaCodiceTerminazione]!', 16, 1)
		RETURN
	END
	--
	-- Restituisco la transcodifica e la descrizione
	--
	SELECT 
		Codice
		, Descrizione 
	FROM dbo.TranscodificaCodiceTerminazione
	WHERE Provenienza = @Provenienza 
		AND CodiceEsterno = @CodiceEsterno 
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgTranscodificaCodiceTerminazione] TO [DataAccessDll]
    AS [dbo];

