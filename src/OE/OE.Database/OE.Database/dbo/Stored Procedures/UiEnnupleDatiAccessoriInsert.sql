


-- =============================================
-- Author:		
-- Create date: 
-- Description:	Inserisce l'ennupla per i dati accessori
-- ModifyDate: 26/03/2019
-- By: LucaB.
-- =============================================



CREATE PROCEDURE [dbo].[UiEnnupleDatiAccessoriInsert]

 @UtenteInserimento as varchar(1024)
,@IDGruppoUtenti as uniqueidentifier
,@CodiceDatoAccessorio as varchar(64)
,@Descrizione as varchar(256)
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
,@Note as varchar(1024)
AS
BEGIN
SET NOCOUNT ON


declare @newId as uniqueidentifier = NEWID()

INSERT INTO [dbo].[EnnupleDatiAccessori]
           ([ID]
           ,[DataInserimento]
           ,[DataModifica]
           ,[UtenteInserimento]
           ,[UtenteModifica]
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
		   ,[Note])
     VALUES
           (@newId
           ,GETDATE()
           ,GETDATE()
           ,@UtenteInserimento
           ,@UtenteInserimento
           ,@IDGruppoUtenti
           ,@CodiceDatoAccessorio
           ,@Descrizione
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
           ,@IDStato
		   ,@Note)

select * from [dbo].[EnnupleDatiAccessori] where ID = @newId

SET NOCOUNT OFF
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleDatiAccessoriInsert] TO [DataAccessUi]
    AS [dbo];

