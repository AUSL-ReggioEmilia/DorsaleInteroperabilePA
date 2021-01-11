

-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-01-16
-- Modify date: 2017-06-07: Ettore: implementato ricerca per "contain" sui campi "descrizione"
-- Description: Ricerca farmaci per i webservice SAC
-- =============================================
CREATE PROCEDURE [codifiche_ws].[FarmaProdottiCerca]
(
 @Descrizione varchar(256) = NULL,
 @PrincipioAttivo varchar(256) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  IF @Top IS NULL OR @Top>200 SET @Top = 200
  
  SELECT TOP (@Top) 
	   PROD.Id
      ,PROD.Descrizione
      ,PRA.Descrizione as PrincipioAttivo
      ,SSN.Descrizione as SSN      
	  ,Forma.Descrizione AS Forma
	  ,GRA.QuantitaGrammatura 
	  ,GRA.UnitaMisuraGrammatura
	  ,codifiche_ws.FarmaGetPosologiaByCodiceMonografia(MONO.CodiceMonografia,20) as Posologia
	  ,codifiche_ws.FarmaGetInterazioniByCodiceMonografia(MONO.CodiceMonografia, 20) as Interazioni	
	  ,NOTE.DescizioneEstesa as Note
  
  FROM  
	codifiche.FarmaProdotti PROD
  
  LEFT JOIN 
	codifiche.FarmaPrincipiAttivi PRA ON PROD.PrincipioAttivo=PRA.Codice
	
  LEFT JOIN 
	codifiche.FarmaRegimeSSN SSN ON PROD.RegimeSSN1 = SSN.Codice
  
  LEFT JOIN codifiche.FarmaGrammature GRA 
	ON PROD.CodiceProdotto = GRA.CodiceProdotto
	AND PROD.PrincipioAttivo = GRA.PrincipioAttivo
  
  LEFT JOIN codifiche.FarmaFormaFarmaceutica FORMA
	ON FORMA.CODICE=PROD.Forma

  LEFT JOIN codifiche.FarmaMonografieProdotti MONO
	ON PROD.CodiceProdotto=MONO.CodiceProdotto	  
  
  LEFT JOIN codifiche.FarmaNotePrescrizione NOTE
    ON NOTE.Codice= PROD.NoteSullaPrescrizione1
  
  WHERE 
      (PROD.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) 
      AND 
      (PRA.Descrizione  LIKE '%' + @PrincipioAttivo + '%' OR @PrincipioAttivo IS NULL) 
  
END
