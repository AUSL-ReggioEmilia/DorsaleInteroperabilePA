
CREATE PROCEDURE [dbo].[UiSistemiDatiAccessoriUpdate]

  @Id AS UNIQUEIDENTIFIER 
 ,@CodiceDatoAccessorio AS VARCHAR(64) 
 ,@IdSistema AS UNIQUEIDENTIFIER
 ,@Attivo AS BIT = NULL
 ,@Eredita AS BIT = NULL
 ,@Sistema AS BIT = NULL
 ,@ValoreDefault AS varchar(1024) = NULL
 
AS
BEGIN
SET NOCOUNT ON

IF @Eredita = 1  SET @Sistema = NULL
IF @Eredita = 1  SET @ValoreDefault = NULL 
 
UPDATE [dbo].[DatiAccessoriSistemi]
   SET [ID] = @Id
      ,[CodiceDatoAccessorio] = @CodiceDatoAccessorio
      ,[IDSistema] = @IdSistema
      ,[Attivo] = @Attivo
      ,[Sistema] = @Sistema
      ,[ValoreDefault] = @ValoreDefault
 WHERE ID = @Id

SELECT * FROM DatiAccessoriSistemi WHERE ID = @Id

SET NOCOUNT OFF
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSistemiDatiAccessoriUpdate] TO [DataAccessUi]
    AS [dbo];

