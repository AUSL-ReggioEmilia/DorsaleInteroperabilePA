


CREATE PROCEDURE [dbo].[UiSistemiInsert1]
 
@Codice as varchar(16) ,
@Descrizione as varchar(128) ,
@Azienda as varchar(16) ,
@Erogante as bit ,
@Richiedente as bit,
@Attivo as bit,
@CancellazionePostInoltro as bit


AS
BEGIN
SET NOCOUNT ON

	RAISERROR  ('Per aggiunggere un nuovo Sistema andare sul SAC!', 16, 1)

--declare @newId as uniqueidentifier = NEWID()

--INSERT INTO [Sistemi]
--           ([ID]
--           ,[Codice]
--           ,[Descrizione]
--           ,[Erogante]
--           ,[Richiedente]
--           ,[CodiceAzienda]
--           ,[Attivo]
--           ,CancellazionePostInoltro)
--     VALUES
--           (@newId
--           ,@Codice
--           ,@Descrizione
--           ,@Erogante
--           ,@Richiedente
--           ,@Azienda
--           ,@Attivo
--           ,@CancellazionePostInoltro)

--select * from [Sistemi] WHERE [ID] = @newId

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSistemiInsert1] TO [DataAccessUi]
    AS [dbo];

