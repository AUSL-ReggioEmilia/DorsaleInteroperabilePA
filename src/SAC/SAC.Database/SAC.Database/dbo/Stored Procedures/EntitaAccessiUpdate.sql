

CREATE PROCEDURE [dbo].[EntitaAccessiUpdate]
(
	  @Id AS uniqueidentifier
	, @Nome AS varchar(128)
	, @Descrizione1 AS varchar(256)
	, @Descrizione2 AS varchar(256)
	, @Descrizione3 AS varchar(256)
	, @Dominio AS varchar(64)
	, @Tipo AS tinyint
	, @Amministratore AS bit
)
AS
BEGIN
	SET NOCOUNT OFF
	BEGIN TRY
		BEGIN TRANSACTION;

		---------------------------------------------------
		-- Aggiorna i dati senza controllo della concorrenza
		---------------------------------------------------
		UPDATE EntitaAccessi
		SET Nome = @Nome
			, Descrizione1 = @Descrizione1
			, Descrizione2 = @Descrizione2
			, Descrizione3 = @Descrizione3
			, Dominio = @Dominio
			, Tipo = @Tipo
			, Amministratore = @Amministratore
		WHERE 
			Id = @Id

		COMMIT TRANSACTION;

		---------------------------------------------------
		-- Completato
		--  Ritorna i dati aggiornati
		---------------------------------------------------
		SELECT *
		FROM EntitaAccessi
		WHERE Id = @Id

		RETURN 0
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
		DECLARE @ErrorLogId INT
		EXECUTE dbo.LogError @ErrorLogId OUTPUT;
		EXECUTE RaiseErrorByIdLog @ErrorLogId 		
		RETURN @ErrorLogId
	END CATCH;

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[EntitaAccessiUpdate] TO [DataAccessUi]
    AS [dbo];

