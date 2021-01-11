


CREATE PROCEDURE [dbo].[UiUnitaOperativeInsert]
 
@Codice as varchar(16) ,
@Descrizione as varchar(128) ,
@Azienda as varchar(16),
@Attivo as bit= NULL


AS
BEGIN
SET NOCOUNT ON

	RAISERROR  ('Per aggiunggere una nuova Unita Operativa andare sul SAC!', 16, 1)

--declare @newId as uniqueidentifier = NEWID()

--INSERT INTO UnitaOperative
--           ([ID]
--           ,[Codice]
--           ,[Descrizione]          
--           ,[CodiceAzienda]
--           ,[Attivo])
--     VALUES
--           (@newId
--           ,@Codice
--           ,@Descrizione
--           ,@Azienda
--           ,@Attivo)

--select * from UnitaOperative WHERE [ID] = @newId

END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiUnitaOperativeInsert] TO [DataAccessUi]
    AS [dbo];

