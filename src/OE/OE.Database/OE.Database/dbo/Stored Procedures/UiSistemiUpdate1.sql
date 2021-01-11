
-- =============================================
-- Author:		/
-- Date:		/
-- Description:	Modifica i sistemi su OE
-- Modify Auhtor: SimoneB
-- Modify Date:	2017-09-01
-- Modify Description: Aggiunto il parametro @CancellazionePostInCarico. Non punta più alla vista SistemiEstesa ma va direttamente sulla tabella Sistemi.
-- =============================================
CREATE PROCEDURE [dbo].[UiSistemiUpdate1]
	@ID as uniqueidentifier,
	@Codice as varchar(16) ,
	@Descrizione as varchar(128) ,
	@Azienda as varchar(16) ,
	@Erogante as bit ,
	@Richiedente as bit,
	@Attivo as bit,
	@CancellazionePostInoltro as bit,
	@CancellazionePostInCarico AS BIT
AS
BEGIN
SET NOCOUNT ON

	IF @ID = '00000000-0000-0000-0000-000000000000'
		RAISERROR  ('Il sistema OE non è modificabile!', 16, 1)
		
	IF EXISTS (SELECT * FROM [dbo].Sistemi WHERE [ID] = @ID)
		--Aggiorno
		UPDATE [dbo].Sistemi
		   SET [Attivo] = @Attivo
			,[CancellazionePostInoltro] = @CancellazionePostInoltro
			,[CancellazionePostInCarico] = @CancellazionePostInCarico
		 WHERE [ID] = @ID
	ELSE
		--L'inserimento viene eseguito su SAC e non su OE.
		INSERT INTO [dbo].[Sistemi]
           ([ID]
           ,[Attivo]
           ,[CancellazionePostInoltro]
           ,[Codice]
           ,[CodiceAzienda]
		   ,[CancellazionePostInCarico]	)
		VALUES
		   ( @ID, 
			 @Attivo, 
			 @CancellazionePostInoltro,
			 @Codice,
			 @Azienda,
			 @CancellazionePostInCarico  )
		   
	SELECT * FROM [Sistemi] WHERE [ID] = @ID

SET NOCOUNT OFF
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSistemiUpdate1] TO [DataAccessUi]
    AS [dbo];

