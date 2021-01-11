

-- =============================================
-- Author:		
-- Create date: 
-- Description:	Copia l'ennupla
-- ModifyDate: 26/03/2019
-- By: LucaB.
-- =============================================

CREATE PROCEDURE [dbo].[UiEnnupleCopy]

@ID as uniqueidentifier,
@UserName as varchar(1024)
as
BEGIN
SET NOCOUNT ON


declare @newId as uniqueidentifier = NEWID()

INSERT INTO [dbo].[Ennuple]
           ([ID]
           ,[DataInserimento]
           ,[DataModifica]
           ,[UtenteInserimento]
           ,[UtenteModifica]
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
           ,[IDStato])
    SELECT @newId as [ID]
      ,GETDATE()
      ,GETDATE()
      ,@UserName
      ,@UserName
      ,[IDGruppoUtenti]
      ,[IDGruppoPrestazioni]
      ,([Descrizione] + ' - Copia') as Descrizione
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
      ,2
  FROM [dbo].[Ennuple]
  where ID = @ID

SET NOCOUNT OFF
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleCopy] TO [DataAccessUi]
    AS [dbo];

