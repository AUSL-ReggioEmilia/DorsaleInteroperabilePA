

CREATE VIEW [Ro].[PazientiIncoerenzaIstat]
AS

SELECT 
	   Id
      ,DataInserimento
      ,Provenienza
      ,IdProvenienza
      ,CodiceIstat
      ,GeneratoDa      
      ,Motivo
  FROM 
	  dbo.PazientiIncoerenzaIstat WITH(NOLOCK)



GO
GRANT SELECT
    ON OBJECT::[Ro].[PazientiIncoerenzaIstat] TO [DataAccessRo]
    AS [dbo];

