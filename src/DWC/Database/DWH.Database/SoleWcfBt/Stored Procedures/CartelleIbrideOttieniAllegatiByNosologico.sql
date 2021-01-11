

-- =============================================
-- Author:		ETTORE GARULLI
-- Create date: 2019-03-29
-- Description:	Restituisce gli allegati PDF relativi ai "referti" che rappresentano cartelle cliniche o cartelle ibride 
-- =============================================
CREATE PROCEDURE [SoleWcfBt].[CartelleIbrideOttieniAllegatiByNosologico]
(
	@NumeroNosologico VARCHAR(16)
	, @AziendaErogante VARCHAR(16) --può essere non valorizzata
)
AS
BEGIN
/*
	
	BT deve vedere tutto: ho usato le viste dello schema "store"

*/
	SET NOCOUNT ON;
	--
	-- Se @AziendaErogante = NULL o '' imposto @AziendaErogante = NULL
	--
	IF ISNULL(@AziendaErogante, '') = '' 
		SET @AziendaErogante = NULL
	--
	-- Restituzione dei dati
	--
	SELECT 
		dbo.GetPazienteAttivoByIdSac(RB.IdPaziente) AS IdPazienteAttivo
		, RB.IdPaziente
		, RB.Cognome
		, RB.Nome
		, ISNULL(RB.CodiceFiscale, '0000000000000000') AS CodiceFiscale
		, RB.DataNascita
		, RB.DataReferto
		, AB.MimeData
		, AB.MimeType
	FROM 
		store.Referti AS RB
		INNER JOIN [Sole].[SistemiCartelle] AS SC
			ON RB.AziendaErogante = SC.AziendaErogante
				AND RB.SistemaErogante = SC.SistemaErogante 
		INNER JOIN [store].[Allegati] AS AB
			ON RB.ID = AB.IdRefertiBase

	WHERE 
		(SC.Abilitato = 1) --Solo i sistemi abilitati
		AND RB.NumeroNosologico = @NumeroNosologico
		AND (RB.AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL)
		AND AB.MimeType = 'application/pdf'
		AND RB.StatoRichiestaCodice = 1 --Completato

	ORDER BY 
		RB.DataReferto ASC

END