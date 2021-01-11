
CREATE PROCEDURE [dbo].[UiPrestazioniDatiAccessoriSelect]

  @Id AS UNIQUEIDENTIFIER = NULL
 ,@CodiceDatoAccessorio AS VARCHAR(64) = NULL
 ,@IdPrestazione AS UNIQUEIDENTIFIER = NULL

AS
BEGIN
SET NOCOUNT ON

SELECT [Id]
      ,[CodiceDatoAccessorio]
      ,[IDPrestazione] 
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

FROM [dbo].[DatiAccessoriPrestazioni] 				  
WHERE 
(@Id IS NULL OR Id = @Id) AND
(@IdPrestazione IS NULL OR IdPrestazione = @IdPrestazione) AND
(@CodiceDatoAccessorio IS NULL OR CodiceDatoAccessorio = @CodiceDatoAccessorio) 
ORDER BY CodiceDatoAccessorio 

SET NOCOUNT OFF
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniDatiAccessoriSelect] TO [DataAccessUi]
    AS [dbo];

