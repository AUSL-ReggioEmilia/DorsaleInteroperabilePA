


CREATE PROCEDURE [dbo].[PazientiUiIncoerenzaIstatSelect]
(
@Id uniqueidentifier
)
AS

BEGIN
  SET NOCOUNT OFF
  
  SELECT 
		Id
		,DataInserimento
		,Provenienza
		,IdProvenienza
		,CodiceIstat
		,GeneratoDa		
		,Motivo
	FROM 
		dbo.PazientiIncoerenzaIstat    		  
	WHERE 
		Id = @Id

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiIncoerenzaIstatSelect] TO [DataAccessUi]
    AS [dbo];

