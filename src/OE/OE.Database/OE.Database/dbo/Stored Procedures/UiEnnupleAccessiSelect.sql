


-- =============================================
-- Author:		
-- Create date: 
-- Description:	Esegue la select di un'ennupla relativa ad un accesso
-- ModifyDate: 26/03/2019
-- By: LucaB.
-- =============================================


CREATE PROCEDURE [dbo].[UiEnnupleAccessiSelect]

AS
BEGIN
SET NOCOUNT ON

SELECT TOP 1000 [ID]
      ,[DataInserimento]
      ,[DataModifica]
      ,[UtenteInserimento]
      ,[UtenteModifica]
      ,[IDGruppoUtenti]
      ,[Descrizione]
      ,[IDSistemaErogante]
      ,[R]
      ,[I]
      ,[S]
      ,[Not]
      ,[IDStato]
	  ,[Note]
  FROM [dbo].[EnnupleAccessi]


SET NOCOUNT OFF
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleAccessiSelect] TO [DataAccessUi]
    AS [dbo];

