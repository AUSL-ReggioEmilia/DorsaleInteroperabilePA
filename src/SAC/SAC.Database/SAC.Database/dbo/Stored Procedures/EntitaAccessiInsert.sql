

CREATE PROCEDURE [dbo].[EntitaAccessiInsert]
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
		-- Inserisce record
		---------------------------------------------------
		INSERT INTO EntitaAccessi
			( Id
			, Nome
			, Descrizione1
			, Descrizione2
			, Descrizione3
			, Dominio
			, Tipo
			, Amministratore )
		VALUES
			( @Id
			, @Nome
			, @Descrizione1
			, @Descrizione2
			, @Descrizione3
			, @Dominio
			, @Tipo
			, @Amministratore)
			
		---------------------------------------------------
		--  Esegue l'inserimento nella tabella EntitaAccessiServizi
		---------------------------------------------------
		exec EntitaAccessiServiziInsert @Id
			
		COMMIT TRANSACTION;

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
    ON OBJECT::[dbo].[EntitaAccessiInsert] TO [DataAccessUi]
    AS [dbo];

