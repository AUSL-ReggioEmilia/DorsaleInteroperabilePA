
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2020-10-15
--
-- Description:	Aggiunge alla coda di OUTPUT un referto da notificare
--				@Operazione = 0=Inserimento, 1=Modifica, 2=Cancellazione
--
-- =============================================
CREATE PROCEDURE [dbo].[CodaRefertiOutputAggiungi]
(
 @IdReferto AS UNIQUEIDENTIFIER
,@IdEsterno AS VARCHAR(64)
,@Operazione SMALLINT
,@AziendaErogante VARCHAR(16)
,@SistemaErogante VARCHAR(16)
,@XmlReferto XML
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @IdCorrelazione AS VARCHAR(64)
	DECLARE @TimeoutCorrelazione INT
	DECLARE @OrdineInvio INT
	--
	-- Valorizzo l'Id di correlazione
	--
	SELECT @IdCorrelazione =  [dbo].[GetCodaRefertiOutputIdCorrelazione] (@AziendaErogante, @SistemaErogante, @IdEsterno)
	--
	-- Valorizzo il timeout di correlazione
	--
	SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput', 'TimeoutCorrelazione'), 1)
	--
	-- Priorità di invio
	--
	SELECT @OrdineInvio = dbo.GetCodaRefertiOutputOrdineInvio(@SistemaErogante)
	--
	-- Cancello notifiche già in coda se è una cancellazione
	--
	IF @Operazione = 2
	BEGIN
		DELETE FROM [dbo].[CodaRefertiOutput]
		WHERE Operazione <> 2 AND IdReferto = @IdReferto
	END

	-------------------------------------------------------------------
	-- Eseguo l'inserimento nella tabella di output standard
	-- dal 2020-10-02 Messaggio = NULL non più dbo.GetRefertoXml2(@IdReferto)
	--
	-------------------------------------------------------------------
	INSERT INTO [dbo].[CodaRefertiOutput] (IdReferto,Operazione, IdCorrelazione, CorrelazioneTimeout
				,  OrdineInvio, Messaggio)
	VALUES(@IdReferto, @Operazione , @IdCorrelazione , @TimeoutCorrelazione
				, @OrdineInvio, @XmlReferto)
END