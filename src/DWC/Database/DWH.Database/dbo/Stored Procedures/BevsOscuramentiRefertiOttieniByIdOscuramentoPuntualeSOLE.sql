




-- =============================================
-- Author:      SimoneB.
-- Create date: 2017-10-11
-- Description: ottengo i referti "toccati" da un oscuramento.
--				Solo i referti "Completati" devono essere inviati a SOLE (R.StatoRichiestaCodice = 1)
--				@IdOscuramento deve essere <> NULL!!!
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentiRefertiOttieniByIdOscuramentoPuntualeSOLE]
(
	@IdOscuramento UNIQUEIDENTIFIER
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON
	IF @IdOscuramento IS NULL
	BEGIN
		RAISERROR('Il parametro @IdOscuramento è obbligatorio.', 16,1)
		RETURN
	END
	--
	-- Per applicare il filtro StatoRichiestaCodice = 1 in PROD con tabella temporanea sembra più efficiente 
	--
	DECLARE @Temp TABLE(ID UNIQUEIDENTIFIER, IdEsterno VARCHAR(64), IdPaziente UNIQUEIDENTIFIER, DataInserimento DATETIME,
			DataModifica DATETIME, AziendaErogante VARCHAR(16), SistemaErogante VARCHAR(16), RepartoErogante VARCHAR(64),
			DataReferto DATETIME, NumeroReferto VARCHAR(16), NumeroNosologico VARCHAR(64), NumeroPrenotazione VARCHAR(32), StatoRichiestaCodice TINYINT )

	INSERT INTO @Temp (ID, IdEsterno, IdPaziente, DataInserimento, DataModifica, AziendaErogante,SistemaErogante,
		RepartoErogante, DataReferto, NumeroReferto, NumeroNosologico,NumeroPrenotazione, StatoRichiestaCodice )
	SELECT R.ID,
		R.IdEsterno,
		R.IdPaziente,
		R.DataInserimento,
		R.DataModifica,
		R.AziendaErogante,
		R.SistemaErogante,
		R.RepartoErogante,
		R.DataReferto,
		R.NumeroReferto,
		R.NumeroNosologico,
		R.NumeroPrenotazione,
		R.StatoRichiestaCodice 
		FROM store.RefertiBase AS R
		--Uso la RefertiBase e passo NULL nel parametro "SpecialitaErogante".
		CROSS APPLY [dbo].[OttieniRefertoOscuramenti](@IdOscuramento,'puntuali','SOLE',r.IdEsterno,r.ID,r.DataPartizione,
					r.AziendaErogante,r.SistemaErogante,r.NumeroNosologico,r.NumeroPrenotazione,r.NumeroReferto,r.IdOrderEntry,null,
					r.RepartoRichiedenteCodice,r.RepartoErogante,NULL) AS RO
	--
	-- Solo i referti "Completati" devono essere inviati a SOLE 
	--
	SELECT * FROM @Temp WHERE StatoRichiestaCodice = 1 

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentiRefertiOttieniByIdOscuramentoPuntualeSOLE] TO [ExecuteFrontEnd]
    AS [dbo];

