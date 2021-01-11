
-- =============================================
-- Author:		ETTORE
-- Create date: 2017-12-13
-- Modify date: 2019-05-20 SANDRO: Rimossa tabella dbo.ConfigurazioniOutputOrchestrazioni
--									Ora le config sono nella tabella dbo.SistemiEroganti

-- Description:	Legge da tabella dedicata se l'orchestrazione delle Note Anamnestiche deve essere ESEGUIRE DIRETTAMENTE la notifica in OUTPUT
--				per il sistema passato come parametro
--				Se restiuisce 1 allora l'orchestrazione eseguirà DIRETTAMENTE la notifica e la DAE scriverà in CodaNoteAnamnetsicheOutputInviati
--				Se restiuisce 0 allora l'orchestrazione NON eseguirà la notifica e la DAE scriverà in CodaNoteAnamnetsicheOutput
-- =============================================
CREATE PROCEDURE [dbo].[ExtNoteAnamnesticheNotificaByOrchestrazione]
(
 @AziendaErogante VARCHAR(16)
,@SistemaErogante VARCHAR(16)
,@RepartoErogante VARCHAR(64) --Non esiste il concetto di @RepartoErogante per le NoteAnamnestiche
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Ret BIT = 0
	--
	--[PrioritaInvioNoteAnamnestiche] = 0 significa che sarà inviato immediatamente tramite la ORC
	--
	IF EXISTS ( SELECT * FROM [dbo].[SistemiEroganti]
				WHERE [AziendaErogante] = @AziendaErogante
					AND [SistemaErogante] = @SistemaErogante 
					AND [PrioritaInvioNoteAnamnestiche] = 0
				)
	BEGIN
		SET @Ret=1
	END
	--
	-- Restituisco
	--
	SELECT @Ret AS NotificaByOrch

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtNoteAnamnesticheNotificaByOrchestrazione] TO [ExecuteExt]
    AS [dbo];

