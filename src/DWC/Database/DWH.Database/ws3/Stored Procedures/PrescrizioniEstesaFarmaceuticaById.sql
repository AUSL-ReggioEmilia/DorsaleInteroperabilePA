-- =============================================
-- Author:		Stefano P.
-- Create date: 2016-11-22
-- Description:	Restituisce i dettagli della Prescrizione Estesa Farmaceutica
-- =============================================
CREATE PROCEDURE [ws3].[PrescrizioniEstesaFarmaceuticaById]
(
  @IdToken UNIQUEIDENTIFIER
 ,@IdPrescrizioniBase UNIQUEIDENTIFIER
 ,@DataPartizione SMALLDATETIME
)
AS
BEGIN
/*
	Per ora viene passato @IdToken ma non viene utilizzato
*/
	SET NOCOUNT ON

	SELECT 
	   [IdPrescrizioniBase]
      ,[DataPartizione]
      ,[Riga]
      ,[DataInserimento]
      ,[DataModifica]
      ,[InfoGenerali_Progressivo]
      ,[InfoGenerali_Quantita]
      ,[InfoGenerali_Posologia]
      ,[InfoGenerali_Note]
      ,[InfoGenerali_Classe]
      ,[InfoGenerali_NotaAifa]
      ,[InfoGenerali_NonSostituibile]
      ,[InfoGenerali_CodMotivazioneNonSostituibile]
      ,[Codifiche_AicSpecialita]
      ,[Codifiche_MinSan10Specialita]
      ,[Codifiche_DescSpecialita]
      ,[Codifiche_CodGruppoTerapeutico]
      ,[Codifiche_CodGruppoEquivalenza]
      ,[Codifiche_DescGruppoEquivalenza]
      ,[PercorsiRegionali_CodPercorsoRegionale]
      ,[PercorsiRegionali_DescPercorsoRegionale]
      ,[PercorsiRegionali_CodAziendaPercorsoRegionale]
      ,[PercorsiRegionali_CodStrutturaPercorsoRegionale]
  FROM 
	[store].[PrescrizioniEstesaFarmaceutica]
  WHERE 
	IdPrescrizioniBase = @IdPrescrizioniBase
	AND DataPartizione = @DataPartizione
  
  RETURN @@ERROR

END