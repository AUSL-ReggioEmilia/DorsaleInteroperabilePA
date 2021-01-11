CREATE PROCEDURE [codifiche_ws].[SOLECodifichePrestazioniSelectByCodici]
(
  @CodiceSpecialita  VARCHAR(16)
 ,@CodicePrestazione VARCHAR(16)
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
		C.CodiceSpecialita = @CodiceSpecialita  
	AND C.CodicePrestazione = @CodicePrestazione 
 
END
