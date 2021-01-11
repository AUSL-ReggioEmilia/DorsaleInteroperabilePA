CREATE PROCEDURE [codifiche_ws].[SOLEBrancheSelectByIdPrestazione]
(
 @IdPrestazione UNIQUEIDENTIFIER
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
	B.CodiceBranca,
    B.DescrizioneBranca
  FROM  
	codifiche.SOLEPrestazioniBranche PB
  INNER JOIN
	codifiche.SOLEBranche B ON PB.BrancaId = B.Id	
  WHERE 
	PB.PRESTAZIONEID = @IdPrestazione
	
END
