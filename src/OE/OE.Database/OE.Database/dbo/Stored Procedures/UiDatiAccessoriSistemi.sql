


-- =============================================
-- Author:		Bitti Simone
-- Modify date: 2016-11-21
-- Description:	Ottiene la lista dei Sistemi associati al Dato Accessorio.
-- =============================================
CREATE PROCEDURE [dbo].[UiDatiAccessoriSistemi]
	@CodiceDatoAccessorio varchar(64)
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY



	SELECT S.ID
		  ,SI.Codice
		  ,ISNULL(SI.Descrizione,'') as Descrizione
		  ,ISNULL(SI.Erogante, 0) as Erogante
		  ,ISNULL(SI.Richiedente, 0) as Richiedente
		  ,CodiceAzienda as Azienda
		  ,ISNULL(SI.Attivo, 0) as Attivo 
		  ,ISNULL(SI.CancellazionePostInoltro, 0) as CancellazionePostInoltro
		  ,IDSistema
	FROM DatiAccessoriSistemi S LEFT JOIN Sistemi SI ON S.IDSistema = SI.ID
	WHERE 
			S.CodiceDatoAccessorio = @CodiceDatoAccessorio

						
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAccessoriSistemi] TO [DataAccessUi]
    AS [dbo];

