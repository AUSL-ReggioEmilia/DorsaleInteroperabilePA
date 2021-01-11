CREATE PROCEDURE [codifiche_ws].[SOLECodifichePrestazioniSelect]
(
 @Id UNIQUEIDENTIFIER
)
AS
BEGIN
  SET NOCOUNT OFF

  
  SELECT 
      C.[Id],
      C.CodicePrestazione,
      C.DescrizionePrestazione,
      C.CodiceDmr,
      C.DescrizioneDmr,
      C.CodiceSpecialita,
      C.DescrizioneSpecialita,
      C.Oscurato,
      C.DataInizioValidita,
      C.DataFineValidita,
      C.NotaInizioValidita,
      C.NotaFineValidita,
      C.Importo,
      C.Esenzione
  FROM  
	codifiche.SOLECodifichePrestazioni C
 	
  WHERE 
      C.Id = @Id

END
