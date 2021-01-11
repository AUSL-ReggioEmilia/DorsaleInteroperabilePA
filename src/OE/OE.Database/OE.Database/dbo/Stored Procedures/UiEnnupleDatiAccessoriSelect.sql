

-- =============================================
-- Author:		
-- Create date: 
-- Description:	Seleziona le ennuple dei dati accessori
-- ModifyDate: 26/03/2019
-- By: LucaB.
-- =============================================



CREATE PROCEDURE [dbo].[UiEnnupleDatiAccessoriSelect]

AS
BEGIN
SET NOCOUNT ON

SELECT TOP 1000 [ID]
      ,[DataInserimento]
      ,[DataModifica]
      ,UtenteInserimento
      ,UtenteModifica
      ,[IDGruppoUtenti]
      ,[CodiceDatoAccessorio]
      ,[Descrizione]
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
	  ,[Note]
  FROM [dbo].[EnnupleDatiAccessori]

SET NOCOUNT OFF
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleDatiAccessoriSelect] TO [DataAccessUi]
    AS [dbo];

