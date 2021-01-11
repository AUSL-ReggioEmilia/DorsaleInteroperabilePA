


-- =============================================
-- Author:		
-- Create date: 
-- Description:	Copia un'ennupla relativa ad un accesso
-- ModifyDate: 26/03/2019
-- By: LucaB.
-- =============================================


CREATE PROCEDURE [dbo].[UiEnnupleAccessiCopy]

@ID as uniqueidentifier,
@UserName as varchar(1024)
as
BEGIN
SET NOCOUNT ON


declare @newId as uniqueidentifier = NEWID()

INSERT INTO [dbo].[EnnupleAccessi]
           ([ID]
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
		   ,[Note])
    SELECT @newId as [ID]
      ,GETDATE()
      ,GETDATE()
      ,@UserName
      ,@UserName
      ,[IDGruppoUtenti]
      ,([Descrizione] + ' - Copia') as Descrizione
      ,[IDSistemaErogante]
      ,[R]
      ,[I]
      ,[S]
      ,[Not]
      ,2
	  ,[Note]
  FROM [dbo].[EnnupleAccessi]
  where ID = @ID

SET NOCOUNT OFF
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleAccessiCopy] TO [DataAccessUi]
    AS [dbo];

