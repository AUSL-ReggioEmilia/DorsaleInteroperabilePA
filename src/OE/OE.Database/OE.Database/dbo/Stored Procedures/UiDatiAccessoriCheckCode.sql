


CREATE PROCEDURE [dbo].[UiDatiAccessoriCheckCode]

 @Codice as varchar(64)

AS
BEGIN
SET NOCOUNT ON

SELECT COUNT(*)
     
  FROM [dbo].[DatiAccessori]
					  
	
WHERE Codice = @Codice 


SET NOCOUNT OFF
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAccessoriCheckCode] TO [DataAccessUi]
    AS [dbo];

