
CREATE PROCEDURE [dbo].[UiSistemiDatiAccessoriSelect]

  @Id AS UNIQUEIDENTIFIER = NULL
 ,@CodiceDatoAccessorio AS VARCHAR(64) = NULL
 ,@IdSistema AS UNIQUEIDENTIFIER = NULL

AS
BEGIN
SET NOCOUNT ON

SELECT [Id]
      ,[CodiceDatoAccessorio]
      ,[IdSistema]
      ,[Attivo]
      ,CASE WHEN Sistema 
	        IS NULL THEN CAST (1 AS BIT)
			ELSE CAST (0 AS BIT)
			END 
			AS Eredita             
      --,ISNULL([Sistema],CAST (0 AS BIT)) AS Sistema   
      ,ISNULL([Sistema], ISNULL((SELECT TOP 1 Sistema FROM DatiAccessori WHERE Codice = @CodiceDatoAccessorio),CAST (0 AS BIT))) AS Sistema   
      --,ISNULL([ValoreDefault],'') AS ValoreDefault     
      ,ISNULL([ValoreDefault],ISNULL((SELECT TOP 1 ValoreDefault FROM DatiAccessori WHERE Codice = @CodiceDatoAccessorio),'')) AS ValoreDefault   

FROM [dbo].[DatiAccessoriSistemi]				  
WHERE 
(@Id IS NULL OR Id = @Id) AND
(@IdSistema IS NULL OR IdSistema = @IdSistema) AND
(@CodiceDatoAccessorio IS NULL OR CodiceDatoAccessorio = @CodiceDatoAccessorio) 
ORDER BY CodiceDatoAccessorio 

SET NOCOUNT OFF
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSistemiDatiAccessoriSelect] TO [DataAccessUi]
    AS [dbo];

