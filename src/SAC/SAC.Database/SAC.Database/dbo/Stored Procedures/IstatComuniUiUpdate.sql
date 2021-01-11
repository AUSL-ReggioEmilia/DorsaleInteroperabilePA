

CREATE PROCEDURE [dbo].[IstatComuniUiUpdate]
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

		UPDATE IstatComuni
		SET
		Nome = @Nome
		, CodiceProvincia = @CodiceProvincia
		, Nazione = @Nazione
		, DataInizioValidita = @DataInizioValidita
		, DataFineValidita = @DataFineValidita
		WHERE Codice = @Codice

		COMMIT TRANSACTION;

		SELECT 
			Codice
			, Nome
			, CodiceProvincia
			, Nazione
			, CASE 
				WHEN GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE()) THEN
				CAST(0 AS BIT) 
				ELSE CAST(1 AS BIT) 
			END AS Obsoleto
			, DataFineValidita AS ObsoletoData
			, Provenienza
			, IdProvenienza
			, DataInserimento
			, DataInizioValidita
			, DataFineValidita
			, CodiceDistretto
			, Cap
			, CodiceCatastale
			, CodiceRegione
			, Sigla
			, CodiceAsl
			, FlagComuneStatoEstero
			, FlagStatoEsteroUE
			, DataUltimaModifica
			, Disattivato
			, CodiceInternoLha
		FROM 
			IstatComuni
		WHERE 
			Codice = @Codice
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
    ON OBJECT::[dbo].[IstatComuniUiUpdate] TO [DataAccessUi]
    AS [dbo];

