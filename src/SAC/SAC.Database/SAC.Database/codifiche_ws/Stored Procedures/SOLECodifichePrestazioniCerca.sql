CREATE PROCEDURE [codifiche_ws].[SOLECodifichePrestazioniCerca]
(
 @CodicePrestazione varchar(16) = NULL,
 @DescrizionePrestazione varchar(256) = NULL,
 @CodiceSpecialita varchar(16) = NULL,
 @DescrizioneSpecialita varchar(256) = NULL,
 @DataInizioValidita date = NULL,
 @DataFineValidita date = NULL,
 @CodiceBranca varchar(16) = NULL,
 @DescrizioneBranca varchar(256) = NULL, 
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  IF @Top IS NULL OR @Top > 200 SET @Top = 200
  
  SELECT DISTINCT TOP (@Top) 
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
  LEFT JOIN
	codifiche.SOLEPrestazioniBranche SB ON C.Id = SB.PRESTAZIONEID
  LEFT JOIN
	codifiche.SOLEBranche B ON SB.BrancaId = B.Id
	
  WHERE 
      (C.CodicePrestazione LIKE '%' + @CodicePrestazione + '%' OR @CodicePrestazione IS NULL) AND 
      (C.DescrizionePrestazione LIKE '%' + @DescrizionePrestazione + '%' OR @DescrizionePrestazione IS NULL) AND 
      (C.CodiceSpecialita LIKE '%' + @CodiceSpecialita + '%' OR @CodiceSpecialita IS NULL) AND 
      (C.DescrizioneSpecialita LIKE '%' + @DescrizioneSpecialita + '%' OR @DescrizioneSpecialita IS NULL) AND 
      (C.DataInizioValidita >= @DataInizioValidita OR @DataInizioValidita IS NULL) AND       
      (C.DataFineValidita <= @DataFineValidita OR @DataFineValidita IS NULL) AND      
      (B.CodiceBranca LIKE '%' + @CodiceBranca + '%' OR @CodiceBranca IS NULL) AND 
      (B.DescrizioneBranca LIKE '%' + @DescrizioneBranca + '%' OR @DescrizioneBranca IS NULL) 

END
