
CREATE PROCEDURE [dbo].[UiPrestazioniDatiAccessoriUpdate]

  @Id AS UNIQUEIDENTIFIER 
 ,@CodiceDatoAccessorio AS VARCHAR(64) 
 ,@IdPrestazione AS UNIQUEIDENTIFIER
 ,@Attivo AS BIT = NULL
 ,@Eredita AS BIT = NULL
 ,@Sistema AS BIT = NULL
 ,@ValoreDefault AS varchar(1024) = NULL
 
AS
BEGIN
SET NOCOUNT ON

IF @Eredita = 1  SET @Sistema = NULL
IF @Eredita = 1  SET @ValoreDefault = NULL 
 
UPDATE [dbo].[DatiAccessoriPrestazioni]
   SET [ID] = @Id
      ,[CodiceDatoAccessorio] = @CodiceDatoAccessorio
      ,[IDPrestazione] = @IdPrestazione
      ,[Attivo] = @Attivo
      ,[Sistema] = @Sistema
      ,[ValoreDefault] = @ValoreDefault
 WHERE ID = @Id

SELECT * FROM DatiAccessoriPrestazioni WHERE ID = @Id

SET NOCOUNT OFF
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniDatiAccessoriUpdate] TO [DataAccessUi]
    AS [dbo];

