
CREATE PROCEDURE [dbo].[IstatMsgIncoerenzaIstatInsert]
(
	@Utente AS varchar(64)
	, @IdProvenienza varchar(64)
	, @CodiceIstat varchar(6)
	, @GeneratoDa varchar(64) --quale flusso ha generato l'incoerenza
	, @Motivo varchar(64)
)
AS
BEGIN
	DECLARE @Provenienza AS VARCHAR(16)	
	SET NOCOUNT ON

	SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		DECLARE @ErrProvenienza AS VARCHAR(200)
		SET @ErrProvenienza = 'Errore di Provenienza: provenienza non trovata in PazientiMsgIncoerenzaIstatInsert(). Utente: ' + @Utente
		RAISERROR(@ErrProvenienza, 16, 1)
		RETURN 1
	END	
	
	INSERT INTO PazientiIncoerenzaIstat(Provenienza,IdProvenienza,CodiceIstat,GeneratoDa,Motivo)
	VALUES (@Provenienza, @IdProvenienza, @CodiceIstat,@GeneratoDa,@Motivo)

	SELECT  @@ROWCOUNT AS ROW_COUNT
END 



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatMsgIncoerenzaIstatInsert] TO [DataAccessDll]
    AS [dbo];

