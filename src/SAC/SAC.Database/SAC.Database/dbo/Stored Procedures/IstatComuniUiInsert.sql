

CREATE PROCEDURE [dbo].[IstatComuniUiInsert]
(
	@Codice varchar(6),
	@Nome varchar(128),
	@CodiceProvincia varchar(3),
	@Nazione bit,
	@DataInizioValidita datetime,
	@DataFineValidita datetime 
)
AS
BEGIN
/*
	Modifica Ettore 2014-05-20: tolto i campi Obsoleto e ObsoletoData
*/
	SET NOCOUNT OFF
	BEGIN TRY
	
		IF @DataInizioValidita IS NULL SET @DataInizioValidita =  '1800-01-01'

		BEGIN TRANSACTION;

		INSERT INTO IstatComuni
			(
			Codice
			,Nome 
			,CodiceProvincia 
			,Nazione
			,DataInizioValidita 
			,DataFineValidita
			)
		VALUES
			(
			@Codice 
			,@Nome 
			,@CodiceProvincia 
			,@Nazione
			,@DataInizioValidita
			,@DataFineValidita 
			)

		COMMIT TRANSACTION;
		--
		--
		--
		RETURN 0
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		DECLARE @ErrorLogId INT
		EXECUTE dbo.LogError @ErrorLogId OUTPUT;

		EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
		RETURN @ErrorLogId
	END CATCH;
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatComuniUiInsert] TO [DataAccessUi]
    AS [dbo];

