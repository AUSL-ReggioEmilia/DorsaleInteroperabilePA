


CREATE PROCEDURE [dbo].[PazientiUiIncoerenzaIstatLista]
(
	@DataInserimentoDal datetime = NULL,
	@DataInserimentoAl datetime = NULL,
	@Provenienza varchar(16) = NULL,
	@IdProvenienza varchar(64) = NULL,
	@CodiceIstat varchar(6) = NULL,	
	@Top int = NULL	
)
WITH RECOMPILE

AS

BEGIN
  DECLARE @Oggi AS DATETIME
  SET NOCOUNT OFF
  
  SET @Oggi = CAST(CONVERT(VARCHAR(10), GETDATE(), 120) AS DATETIME)

  SELECT Top (COALESCE(@Top,100))     
	   Id
      ,DataInserimento
      ,Provenienza
      ,IdProvenienza
      ,CodiceIstat
      ,GeneratoDa      
      ,Motivo
  FROM 
	  PazientiIncoerenzaIstat as PA
	
  WHERE 
      (PA.DataInserimento BETWEEN COALESCE(@DataInserimentoDal,@Oggi) AND COALESCE(@DataInserimentoAl,GETDATE()) ) AND
      (PA.Provenienza = @Provenienza OR @Provenienza IS NULL) AND 
      (PA.IdProvenienza = @IdProvenienza OR @IdProvenienza IS NULL) AND 
      (PA.CodiceIstat = @CodiceIstat OR @CodiceIstat IS NULL)     
  ORDER BY 
      PA.DataInserimento DESC

END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiIncoerenzaIstatLista] TO [DataAccessUi]
    AS [dbo];

