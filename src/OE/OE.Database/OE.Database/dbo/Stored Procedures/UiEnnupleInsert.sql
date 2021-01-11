

-- =============================================
-- Author:		
-- Create date: 
-- Description:	Inserisce l'ennupla
-- ModifyDate: 26/03/2019
-- By: LucaB.
-- =============================================


CREATE PROCEDURE [dbo].[UiEnnupleInsert]

 @UtenteInserimento as varchar(1024)
,@IDGruppoUtenti as uniqueidentifier
,@IDGruppoPrestazioni as uniqueidentifier
,@Descrizione as varchar(256)
,@Note as varchar(1024)
,@OrarioInizio as time(0)
,@OrarioFine as time(0)
,@Lunedi as bit
,@Martedi as bit
,@Mercoledi as bit
,@Giovedi as bit
,@Venerdi as bit
,@Sabato as bit
,@Domenica as bit
,@IDUnitaOperativa as uniqueidentifier
,@IDSistemaRichiedente as uniqueidentifier
,@CodiceRegime as varchar(16)
,@CodicePriorita as varchar(16)
,@Inverso as bit
,@IDStato as tinyint
AS
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
     VALUES
           (@newId
           ,GETDATE()
           ,GETDATE()
           ,@UtenteInserimento
           ,@UtenteInserimento
           ,@IDGruppoUtenti
           ,@IDGruppoPrestazioni
           ,@Descrizione
		   ,@Note
           ,@OrarioInizio
           ,@OrarioFine
           ,@Lunedi
           ,@Martedi
           ,@Mercoledi 
           ,@Giovedi 
           ,@Venerdi 
           ,@Sabato
           ,@Domenica
           ,@IDUnitaOperativa 
           ,@IDSistemaRichiedente 
           ,@CodiceRegime 
           ,@CodicePriorita 
           ,@Inverso
           ,@IDStato)

select * from [dbo].[Ennuple] where ID = @newId

SET NOCOUNT OFF
END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleInsert] TO [DataAccessUi]
    AS [dbo];

