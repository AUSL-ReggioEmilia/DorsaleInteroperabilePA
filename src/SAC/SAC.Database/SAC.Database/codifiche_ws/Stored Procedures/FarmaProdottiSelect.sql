-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-07-27
-- Description: Recupera tutte le informazioni disponibili su un farmaco (webservice SAC), 
--				per la ricerca passare l'id oppure il codice
-- Modify date: 2016-01-04 Stefano P: Eliminato campo OperazioneTecnica
-- =============================================
CREATE PROCEDURE [codifiche_ws].[FarmaProdottiSelect]
(
 @Id UNIQUEIDENTIFIER,
 @CodiceProdotto VARCHAR(16)
)
AS
BEGIN
  
  SELECT  PROD.[Id]
      , PROD.[CodiceProdotto]
      , PROD.[CodiceEAN]
      , PROD.[CodiceEMEA]
      , PROD.[CodiceInternoDitta]
      , PROD.[Descrizione]
      , PROD.[NoPrezzo]
      , PROD.[DataPrezzo1]
      , PROD.[TipoPrezzo1]
      , PROD.[Prezzo1Euro]
      , PROD.[DataPrezzo2]
      , PROD.[TipoPrezzo2]
      , PROD.[Prezzo2Euro]
      , PROD.[DataPrezzo3]
      , PROD.[TipoPrezzo3]
      , PROD.[Prezzo3Euro]
      , PROD.[UnitaDiMisura]
      , PROD.[PrezzoUMEuro]
      , PROD.[TariffaDataVigore]
      , PROD.[TariffaUM]
      , PROD.[TariffaEuro]
      , PROD.[DataDalDitta1]
      , PROD.[Ditta1Produttrice]
      , PROD.[DivisioneDitta1]
      , PROD.[DataDalDitta2]
      , PROD.[Ditta2Produttrice]
      , PROD.[DivisioneDitta2]
      , PROD.[DataDalAssInde1]
      , PROD.[AssInde1]
      , PROD.[DataDalAssInde2]
      , PROD.[AssInde2]
      , PROD.[DittaConcessionaria]
      , PROD.[DivisioneDittaConcessionaria]
      , PROD.[ATC]
      , PROD.[GruppoTerapeutico]
      , PROD.[DataPrimaRegistrazione]
      , PROD.[DataInizioCommercio]
      , PROD.[Commercio]
      , PROD.[SostituisceIl]
      , PROD.[SostituitoDa]
      , PROD.[ProdottoBaseGenerico]
      , PROD.[ProdottoDiRiferimento]
      , PROD.[CodiceNomenclatore]
      , PROD.[ProntuarioDal]
      , PROD.[ProntuarioAl]
      , PROD.[DataDalSSNClasse1]
      , PROD.[Classe1]
      , PROD.[DataDalSSNClasse2]
      , PROD.[Classe2]
      , PROD.[DataDalPrescrivibilita1]
      , PROD.[Prescrivibilita1]
      , PROD.[DataDalPrescrivibilita2]
      , PROD.[Prescrivibilita2]
      , PROD.[DataDalTipoRicetta1]
      , PROD.[TipoRicetta1]
      , PROD.[DataDalTipoRicetta2]
      , PROD.[TipoRicetta2]
      , PROD.[DataDalNotePrescrizione1]
      , PROD.[DataDalNotePrescrizione2]
      , PROD.[TipoProdotto]
      , PROD.[Caratteristica]
      , PROD.[Obbligatorieta]
      , PROD.[Contenitore]
      , PROD.[Stupefacente]
      , PROD.[CodiceIVA]
      , PROD.[Temperatura]
      , PROD.[Validita]
      , PROD.[CodiceDegrassi]
      , PROD.[Particolare]
      , PROD.[VendibilitaAl]
      , PROD.[Ricommerciabilita]
      , PROD.[RitiroDefinitivo]
      , PROD.[DataInizioEsaurimento]
      , PROD.[DegrassiBDF400]
      , PROD.[DataPrezzoRimborso]
      , PROD.[PrezzoMaxRimborsoEuro]
      , PRA.Descrizione as PrincipioAttivo
      , SSN1.Descrizione as RegimeSSN1
      , SSN2.Descrizione as RegimeSSN2
	  , Forma.Descrizione AS FormaFarmaceutica
	  , GRA.QuantitaGrammatura 
	  , GRA.UnitaMisuraGrammatura
	  , codifiche_ws.FarmaGetPosologiaByCodiceMonografia(MONO.CodiceMonografia,999) as Posologia
	  , codifiche_ws.FarmaGetInterazioniByCodiceMonografia(MONO.CodiceMonografia, 999) as Interazioni	
	  , NOTE1.DescizioneEstesa as NotePrescrizione1
	  , NOTE2.DescizioneEstesa as NotePrescrizione2
  
  FROM  
	codifiche.FarmaProdotti PROD
  
  LEFT JOIN 
	codifiche.FarmaPrincipiAttivi PRA ON PROD.PrincipioAttivo=PRA.Codice
	
  LEFT JOIN 
	codifiche.FarmaRegimeSSN SSN1 ON PROD.RegimeSSN1 = SSN1.Codice

  LEFT JOIN 
	codifiche.FarmaRegimeSSN SSN2 ON PROD.RegimeSSN2 = SSN2.Codice
  
  LEFT JOIN codifiche.FarmaGrammature GRA 
	ON PROD.CodiceProdotto = GRA.CodiceProdotto
	AND PROD.PrincipioAttivo = GRA.PrincipioAttivo
  
  LEFT JOIN codifiche.FarmaFormaFarmaceutica FORMA
	ON FORMA.CODICE = PROD.Forma

  LEFT JOIN codifiche.FarmaMonografieProdotti MONO
	ON PROD.CodiceProdotto=MONO.CodiceProdotto	  
  
  LEFT JOIN codifiche.FarmaNotePrescrizione NOTE1
    ON NOTE1.Codice = PROD.NoteSullaPrescrizione1
     
  LEFT JOIN codifiche.FarmaNotePrescrizione NOTE2
    ON NOTE2.Codice = PROD.NoteSullaPrescrizione2

          
  WHERE
	(@CodiceProdotto IS NULL AND PROD.[Id] = @Id)
	OR
	(@Id IS NULL AND PROD.CodiceProdotto = @CodiceProdotto)
	
END
	
