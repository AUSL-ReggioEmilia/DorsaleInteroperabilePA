

CREATE PROCEDURE [frontend].[RefertiNoteCancella]
(
	@IdNote uniqueidentifier	--Id della nota
)
AS
BEGIN
/*

	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsRefertiNoteCancella
*/
	SET NOCOUNT ON;

	UPDATE RefertiNote	
		SET Cancellata = 1
	WHERE
		Id = @IdNote
	
	SELECT * FROM RefertiNote
	WHERE Id = @IdNote
	
END


