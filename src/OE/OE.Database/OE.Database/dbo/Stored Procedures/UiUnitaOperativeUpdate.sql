
CREATE PROCEDURE [dbo].[UiUnitaOperativeUpdate]

@ID as uniqueidentifier,
@Codice as varchar(16),
@Descrizione as varchar(128),
@Azienda as varchar(16),
@Attivo as bit


AS
BEGIN
SET NOCOUNT ON

	IF @ID = '00000000-0000-0000-0000-000000000000'
		RAISERROR  ('L''Unita Operativa OE non è modificabile!', 16, 1)

	IF EXISTS (SELECT * FROM [dbo].UnitaOperativeEstesa	 WHERE [ID] = @ID)
		--Aggiorno
		UPDATE [dbo].UnitaOperativeEstesa
		   SET [Attivo] = @Attivo
		 WHERE [ID] = @ID
	ELSE
		INSERT INTO [dbo].UnitaOperativeEstesa ([ID], [Attivo])
		VALUES( @ID, @Attivo)

	SELECT * FROM UnitaOperative WHERE [ID] = @ID
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiUnitaOperativeUpdate] TO [DataAccessUi]
    AS [dbo];

