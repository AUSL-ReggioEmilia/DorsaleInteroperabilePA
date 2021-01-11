
CREATE PROCEDURE [dbo].[LogLHABT]
	@DataVariazione datetime,
	@IdLHA varchar(20),
	@TipoOperazione varchar(1),
	@XmlMessaggio xml
AS
BEGIN

	If NOT(@IdLHA IS NULL)
	BEGIN
		INSERT INTO [Log]
			(DataVariazione,
			IdLHA,
			TipoOperazione,
			XmlMessaggio)
		VALUES
			(@DataVariazione,
			@IdLHA,
			@TipoOperazione,
			@XmlMessaggio)
			
		SELECT * FROM [Log]
			WHERE Id = @@IDENTITY
	END
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[LogLHABT] TO [Execute Biztalk]
    AS [dbo];

