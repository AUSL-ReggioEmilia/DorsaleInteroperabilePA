CREATE PROCEDURE [codifiche_admin].[SOLECodifichePrestazioniCerca]
(
 @CodicePrestazione varchar(16) = NULL,
 @DescrizionePrestazione varchar(256) = NULL,
 @CodiceSpecialita varchar(16) = NULL,
 @DescrizioneSpecialita varchar(256) = NULL,
 @DataInizioValidita date = NULL,
 @DataFineValidita date = NULL,
 @CodiceBranca varchar(16),
 @DescrizioneBranca varchar(256) = NULL, 
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  SELECT DISTINCT TOP (ISNULL(@Top, 200)) 
        
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
      C.Esenzione,
  --concatenazione di codici e descrizioni di tutte le branche della prestazione
	  (
       STUFF((SELECT CAST(', [' + B2.CodiceBranca + '] ' + ISNULL(B2.DescrizioneBranca,'') AS VARCHAR(MAX)) 
		  FROM 
			codifiche.SOLEPrestazioniBranche PB2 
		  INNER JOIN
			codifiche.SOLEBranche B2 ON PB2.BrancaId = B2.Id AND C.Id = PB2.PrestazioneId
		  ORDER BY B2.CodiceBranca
		  FOR XML PATH ('')), 1, 2, '')
	  ) AS Branche

  FROM  
	codifiche.SOLECodifichePrestazioni C
  LEFT JOIN
	codifiche.SOLEPrestazioniBranche PB ON C.Id = PB.PrestazioneId
  LEFT JOIN
	codifiche.SOLEBranche B ON PB.BrancaId = B.Id
	
  WHERE 
      (C.CodicePrestazione LIKE '%' + @CodicePrestazione + '%' OR @CodicePrestazione IS NULL) AND 
      (C.DescrizionePrestazione LIKE '%' + @DescrizionePrestazione + '%' OR @DescrizionePrestazione IS NULL) AND 
      (C.CodiceSpecialita LIKE '%' + @CodiceSpecialita + '%' OR @CodiceSpecialita IS NULL) AND 
      (C.DescrizioneSpecialita LIKE '%' + @DescrizioneSpecialita + '%' OR @DescrizioneSpecialita IS NULL) AND 
      (C.DataInizioValidita >= @DataInizioValidita OR @DataInizioValidita IS NULL) AND       
      (C.DataFineValidita <= @DataFineValidita OR @DataFineValidita IS NULL) AND      
      (B.CodiceBranca LIKE '%' + @CodiceBranca + '%' OR @CodiceBranca IS NULL) AND 
      (B.DescrizioneBranca LIKE '%' + @DescrizioneBranca + '%' OR @DescrizioneBranca IS NULL) 

  ORDER BY CodicePrestazione, DescrizionePrestazione
END
