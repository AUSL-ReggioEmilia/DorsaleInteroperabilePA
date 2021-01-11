
-- =============================================
-- Author:		
-- Create date: 
-- Description:	Restituisce le prime 1000 ennuple
-- ModifyDate: 26/03/2019
-- By: LucaB.
-- =============================================


CREATE PROCEDURE [dbo].[UiEnnupleSelect]

AS
BEGIN
SET NOCOUNT ON

SELECT TOP 1000 [ID]
      ,[DataInserimento]
      ,[DataModifica]
      ,UtenteInserimento
      ,UtenteModifica
      ,[IDGruppoUtenti]
      ,[IDGruppoPrestazioni]
      ,[Descrizione]
	  ,[Note]
      ,[OrarioInizio]
      ,[OrarioFine]
      ,[Lunedi]
      ,[Martedi]
      ,[Mercoledi]
      ,[Giovedi]
      ,[Venerdi]
      ,[Sabato]
      ,[Domenica]
      ,[IDUnitaOperativa]
      ,[IDSistemaRichiedente]
      ,[CodiceRegime]
      ,[CodicePriorita]
      ,[Not]
      ,[IDStato]
  FROM [dbo].[Ennuple]

SET NOCOUNT OFF
END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleSelect] TO [DataAccessUi]
    AS [dbo];

