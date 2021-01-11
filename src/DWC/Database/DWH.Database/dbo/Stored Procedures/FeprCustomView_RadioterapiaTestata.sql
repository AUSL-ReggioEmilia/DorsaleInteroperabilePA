
CREATE PROCEDURE [dbo].[FeprCustomView_RadioterapiaTestata]
(
	@IdRefertiBase UNIQUEIDENTIFIER
)
AS
/* 
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store"
	Uso le nuove funzioni GetRefertiAttributoAttributo2() con data di partizione
*/
	SET NOCOUNT ON
	
	SELECT	ID,
		IdEsterno,
		--MODIFICA ETTORE 2012-09-10: traslo l'idpaziente nell'idpaziente attivo		
		dbo.GetPazienteAttivoByIdSac(IdPaziente) AS IdPaziente,
		--
		--Referto
		--
		AziendaErogante,
		SistemaErogante,
		RepartoErogante,
		CONVERT(VARCHAR(20), DataReferto, 103) AS DataReferto,
		NumeroReferto,
		/*NumeroNosologico,
		NumeroPrenotazione,*/

		--
		--Paziente
		--
		Cognome,
		Nome,
		Sesso,
		CodiceFiscale,
		CONVERT(VARCHAR(20), DataNascita, 103) AS DataNascita,
		ComuneNascita,
		CodiceSanitario,
		--
		--Classificazione
		--
		RepartoRichiedenteCodice,
		RepartoRichiedenteDescr + ' (' + RepartoRichiedenteCodice + ') ' AS RepartoRichiedenteDescr,
		
		/*PrioritaCodice,
		PrioritaDescr,
		StatoRichiestaCodice,
		StatoRichiestaDescr,*/

		TipoRichiestaCodice,
		TipoRichiestaDescr,

		CAST(ISNULL(dbo.GetRefertiAttributo2(Referti.Id, DataPartizione, 'CourseId'),'') AS VARCHAR(50)) AS CourseId,
		CAST(ISNULL(dbo.GetRefertiAttributo2(Referti.Id, DataPartizione, 'PlanSetupId'),'') AS VARCHAR(50)) AS PlanSetupId
		--
		-- Visualizzo nella testata la quantità totale 
		--
--		(SELECT	  CONVERT(decimal(10,2), 
--						  SUM(CONVERT(real, IsNull(dbo.GetPrestazioniAttributo(Prestazioni.Id, Prestazioni2.DataPartizione, 'Quantita'),0)))
--						  )
--		FROM Referti LEFT JOIN Prestazioni2 ON Referti.ID = Prestazioni.IDRefertiBase WHERE Referti.Id = @IdRefertiBase) AS QuantitaTotale


	FROM frontend.Referti
	WHERE ID = @IdRefertiBase


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprCustomView_RadioterapiaTestata] TO [ExecuteFrontEnd]
    AS [dbo];

