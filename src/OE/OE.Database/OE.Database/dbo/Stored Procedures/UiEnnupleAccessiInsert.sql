


-- =============================================
-- Author:		
-- Create date: 
-- Description:	Inserisce un'ennupla relativa ad un accesso
-- ModifyDate: 26/03/2019
-- By: LucaB.
-- =============================================


CREATE PROCEDURE [dbo].[UiEnnupleAccessiInsert]

 @UtenteInserimento as varchar(64)
,@IDGruppoUtenti as uniqueidentifier = NULL
,@Descrizione as varchar(256)
,@IDSistemaErogante as uniqueidentifier = NULL
,@Lettura as bit
,@Inoltro as bit
,@Scrittura as bit
,@Inverso as bit = 0
,@IDStato as tinyint
,@Note as varchar(1024)
AS
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
           ,R
           ,I
           ,S
           ,[Not]
           ,[IDStato]
		   ,[Note])
     VALUES
           (@newId
           ,GETDATE()
           ,GETDATE()
           ,@UtenteInserimento
           ,@UtenteInserimento
           ,@IDGruppoUtenti          
           ,@Descrizione                 
           ,@IDSistemaErogante
           ,@Lettura 
           ,@Scrittura
           ,@Inoltro 
           ,@Inverso
           ,@IDStato
		   ,@Note)

select * from [dbo].[EnnupleAccessi] where ID = @newId

SET NOCOUNT OFF
END










GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleAccessiInsert] TO [DataAccessUi]
    AS [dbo];

