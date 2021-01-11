

CREATE PROCEDURE [dbo].[UiDatiAccessoriPrestazioniSelect]

  @ID AS UNIQUEIDENTIFIER = NULL
 ,@CodiceDatoAccessorio AS VARCHAR(64) = NULL
 ,@IDPrestazione AS UNIQUEIDENTIFIER = NULL

AS
BEGIN
SET NOCOUNT ON

SELECT [ID]
      ,[CodiceDatoAccessorio]
      ,[IDPrestazione]
      ,[Attivo]
      ,[Sistema]
      ,[ValoreDefault]
      ,CAST(0 AS BIT) AS Eredita
      
FROM [dbo].[DatiAccessoriPrestazioni]				  
WHERE (@CodiceDatoAccessorio is null or CodiceDatoAccessorio like '%'+@CodiceDatoAccessorio+'%') 
ORDER BY CodiceDatoAccessorio 

SET NOCOUNT OFF
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAccessoriPrestazioniSelect] TO [DataAccessUi]
    AS [dbo];

