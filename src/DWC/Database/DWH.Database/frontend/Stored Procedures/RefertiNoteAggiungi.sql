

CREATE PROCEDURE [frontend].[RefertiNoteAggiungi]
(
	@IdReferti uniqueidentifier,	--il referto a cui associare la nota
	@Utente as varchar(100),		--l'utente che esegue l'operazione
	@Nota as text
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsRefertiNoteAggiungi
*/

	SET NOCOUNT ON;
	
	DECLARE @Id AS Uniqueidentifier
	
	SET @Id = Newid()
	
	INSERT INTO RefertiNote(Id, IdRefertiBase, Utente, Data, Notificata , Nota)
	VALUES (@Id, @IdReferti, @Utente, GetDate(), 0, @Nota)
	
	SELECT * FROM RefertiNote
	WHERE Id = @Id
	
END


