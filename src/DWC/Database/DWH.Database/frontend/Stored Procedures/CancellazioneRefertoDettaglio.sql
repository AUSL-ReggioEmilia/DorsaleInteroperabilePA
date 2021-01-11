



-- =============================================
-- Author:		ETTORE
-- Create date: 2015-05-22
-- Description:	Restituisce le informazioni relative al referto passato da usare nella pagina di cancellazione logica di un referto
--				Sostituisce la dbo.FevsCancellazioneRefertoDettaglio
--				Uso la vista store.RefertiBase al posto della dbo.RefertiBase
-- Modify date: 2019-01-31 - ETTORE: Eliminato uso della tabella "dbo.RepartiEroganti"
-- =============================================
CREATE PROCEDURE [frontend].[CancellazioneRefertoDettaglio]
(
	@IdRefertiBase  uniqueidentifier
)
AS
SET NOCOUNT ON
BEGIN

	SELECT
		RefertiBase.Id,
		--mi assicuro di restituire il paziente attivo associato a RefertiBase.IdPaziente
		dbo.GetPazienteAttivoByIdSac(RefertiBase.IdPaziente) AS IdPaziente,
		RefertiBase.NumeroReferto,
		RefertiBase.DataReferto,
		RefertiBase.RepartoErogante,
		RefertiBase.Cancellato,
		SistemiEroganti.RuoloManager --il ruolo
	FROM
		store.RefertiBase
		LEFT OUTER JOIN SistemiEroganti 
		ON RefertiBase.AziendaErogante = SistemiEroganti.AziendaErogante
			AND RefertiBase.SistemaErogante = SistemiEroganti.SistemaErogante
	WHERE
		RefertiBase.Id=@IdRefertiBase

END

