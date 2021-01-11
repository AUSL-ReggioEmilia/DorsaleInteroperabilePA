-- =============================================
-- Author:		Stefano P.
-- Create date: 2016-11-22
-- Description:	Restituisce i dettagli della Prescrizione Estesa Specialistica
-- =============================================
CREATE PROCEDURE [ws3].[PrescrizioniEstesaSpecialisticaById]
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
      ,[InfoGenerali_Note]
      ,[InfoGenerali_CodBranca]
      ,[InfoGenerali_TipoAccesso]
      ,[Codifiche_CodDmRegionale]
      ,[Codifiche_CodCatalogoRegionale]
      ,[Codifiche_DescDmRegionale]
      ,[Codifiche_DescCatalogoRegionale]
      ,[Codifiche_CodAziendale]
      ,[Codifiche_DescAziendale]
      ,[PercorsiRegionali_CodPacchettoRegionale]
      ,[PercorsiRegionali_CodPercorsoRegionale]
      ,[PercorsiRegionali_DescPercorsoRegionale]
      ,[PercorsiRegionali_CodAziendaPercorsoRegionale]
      ,[PercorsiRegionali_CodStrutturaPercorsoRegionale]
      ,[Dm915_Nota]
      ,[Dm915_Erog]
      ,[Dm915_Appr]
      ,[Dm915_Pat]
	FROM 
		[store].[PrescrizioniEstesaSpecialistica]
	WHERE 
		IdPrescrizioniBase = @IdPrescrizioniBase
		AND DataPartizione = @DataPartizione
  
	RETURN @@ERROR

END