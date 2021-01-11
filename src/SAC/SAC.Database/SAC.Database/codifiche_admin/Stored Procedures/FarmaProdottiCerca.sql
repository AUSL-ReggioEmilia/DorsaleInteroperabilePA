-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-01-29
-- Description: Ricerca prodotti con filtri opzionali
-- =============================================
CREATE PROC [codifiche_admin].[FarmaProdottiCerca]
(
 @CodiceProdotto varchar(16) = NULL,
 @CodiceEAN varchar(16) = NULL,
 @CodiceEMEA varchar(20) = NULL,
 @Descrizione varchar(256) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  SELECT TOP (ISNULL(@Top, 100)) 
      [Id],
      [CodiceProdotto],
      [CodiceEAN],
      [CodiceEMEA],
      [CodiceInternoDitta],
      [Descrizione],
      [NoPrezzo],
      [DataPrezzo1],
      [TipoPrezzo1],
      [Prezzo1Lire],
      [Prezzo1Euro],
      [DataPrezzo2],
      [TipoPrezzo2],
      [Prezzo2Lire],
      [Prezzo2Euro],
      [DataPrezzo3],
      [TipoPrezzo3],
      [Prezzo3Lire],
      [Prezzo3Euro],
      [UnitaDiMisura],
      [PrezzoUMLire],
      [PrezzoUMEuro],
      [TariffaDataVigore],
      [TariffaUM],
      [TariffaLire],
      [TariffaEuro],
      [DataDalDitta1],
      [Ditta1Produttrice],
      [DivisioneDitta1],
      [DataDalDitta2],
      [Ditta2Produttrice],
      [DivisioneDitta2],
      [DataDalAssInde1],
      [AssInde1],
      [DataDalAssInde2],
      [AssInde2],
      [DittaConcessionaria],
      [DivisioneDittaConcessionaria],
      [ATC],
      [GruppoTerapeutico],
      [PrincipioAttivo],
      [DataPrimaRegistrazione],
      [DataInizioCommercio],
      [Commercio],
      [SostituisceIl],
      [SostituitoDa],
      [ProdottoBaseGenerico],
      [ProdottoDiRiferimento],
      [CodiceNomenclatore],
      [ProntuarioDal],
      [ProntuarioAl],
      [DataDalSSNClasse1],
      [RegimeSSN1],
      [Classe1],
      [DataDalSSNClasse2],
      [RegimeSSN2],
      [Classe2],
      [DataDalPrescrivibilita1],
      [Prescrivibilita1],
      [DataDalPrescrivibilita2],
      [Prescrivibilita2],
      [DataDalTipoRicetta1],
      [TipoRicetta1],
      [DataDalTipoRicetta2],
      [TipoRicetta2],
      [DataDalNotePrescrizione1],
      [NoteSullaPrescrizione1],
      [DataDalNotePrescrizione2],
      [NoteSullaPrescrizione2],
      [TipoProdotto],
      [Caratteristica],
      [Obbligatorieta],
      [Forma],
      [Contenitore],
      [Stupefacente],
      [CodiceIVA],
      [Temperatura],
      [Validita],
      [CodiceDegrassi],
      [Particolare],
      [VendibilitaAl],
      [Ricommerciabilita],
      [RitiroDefinitivo],
      [DataInizioEsaurimento],
      [DegrassiBDF400],
      [DataPrezzoRimborso],
      [PrezzoMaxRimborsoLire],
      [PrezzoMaxRimborsoEuro]
  FROM  [codifiche].[FarmaProdotti]
  WHERE 
      (CodiceProdotto LIKE @CodiceProdotto + '%' OR @CodiceProdotto IS NULL) AND 
      (CodiceEAN LIKE @CodiceEAN + '%' OR @CodiceEAN IS NULL) AND 
      (CodiceEMEA LIKE @CodiceEMEA + '%' OR @CodiceEMEA IS NULL) AND 
      (Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL)
END
