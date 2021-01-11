
CREATE PROCEDURE [dbo].[UiSistemiDatiAccessoriInsert](
	@IDSistema as uniqueidentifier,
	@CodiceDatoAccesorio as varchar (64)
)
AS
BEGIN
	SET NOCOUNT ON

	-- Controllo se c'è in locale
	IF NOT EXISTS (SELECT * FROM SistemiEstesa WHERE Id = @IDSistema)
	BEGIN
		-- Allineo tabella locale
		EXEC [dbo].[CoreSistemiEstesaAllinea] @IDSistema, NULL, NULL
	END
	
	DECLARE @newId as uniqueidentifier = NEWID()

	INSERT INTO [dbo].DatiAccessoriSistemi
			   ([ID]
			   ,IDSistema
			   ,CodiceDatoAccessorio)
		 VALUES
			   (@newId
			   ,@IDSistema
			   ,@CodiceDatoAccesorio)

	SELECT * FROM DatiAccessoriSistemi WHERE ID = @newId
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSistemiDatiAccessoriInsert] TO [DataAccessUi]
    AS [dbo];

