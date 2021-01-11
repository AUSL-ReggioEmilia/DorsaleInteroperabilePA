
CREATE PROCEDURE [dbo].[FeprRefertiStoricoDettaglio]
(
	@IdPaziente UNIQUEIDENTIFIER
	, @AziendaErogante VARCHAR (16)=null
	, @SistemaErogante VARCHAR (16)=null
	, @RepartoErogante VARCHAR (64)=null
	, @PrestazioneCodice VARCHAR (16)=null
	, @SoundexPrestazione VARCHAR (50)=null
	, @SezioneCodice VARCHAR (16)=null
	, @SoundexSezione VARCHAR (50)=null
)
AS
BEGIN 
/*
	Restituice la lista dei risultati per paziente, sezione e prestazione
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store" 
*/
	SET NOCOUNT ON
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)
	--
	--
	--	
	SELECT	
		Prestazioni.ID,
		Referti.Id AS IdRefertiBase,
		IsNull(Referti.Cognome, '') + ' ' + IsNull(Referti.Nome, '') as Paziente,
		Prestazioni.DataErogazione,
		Prestazioni.DataModifica,
		Prestazioni.SezioneCodice,
		LTRIM(RTRIM(Prestazioni.SezioneDescrizione)) + ' (' + Prestazioni.SezioneCodice + ') ' as Sezione,
		PrestazioneCodice,
		PrestazioneDescrizione,
		--Prestazioni.RunningNumber, --ORIGINALE, ma la vista store.Prestazioni non lo restituisce
		dbo.GetPrestazioniAttributoInteger( Prestazioni.Id, Prestazioni.DataPartizione, 'RunningNumber') as RunningNumber,		
		Prestazioni.GravitaCodice,
		Prestazioni.GravitaDescrizione,
		Prestazioni.Risultato,
		Prestazioni.ValoriRiferimento,
		Prestazioni.SezionePosizione,
		Prestazioni.PrestazionePosizione,
		Prestazioni.Commenti,
		Referti.DataReferto,
		Referti.NumeroReferto
	FROM		
		frontend.Referti AS Referti
		INNER JOIN @TablePazienti Pazienti
			ON Referti.IdPaziente = Pazienti.Id
		LEFT JOIN store.Prestazioni AS Prestazioni
			ON Referti.ID = Prestazioni.IDRefertiBase
	WHERE	
		(Referti.AziendaErogante like @AziendaErogante or @AziendaErogante  is null) AND
		(Referti.SistemaErogante like @SistemaErogante or @SistemaErogante is null) AND
		(Referti.RepartoErogante like @RepartoErogante or @RepartoErogante is null) AND
		(Prestazioni.PrestazioneCodice like @PrestazioneCodice  or @PrestazioneCodice is null) AND
		(Prestazioni.SoundexPrestazione Like Soundex(@SoundexPrestazione) or @SoundexPrestazione is null) AND
		(SezioneCodice like @SezioneCodice or @SezioneCodice is null) AND
		(Prestazioni.SoundexSezione Like Soundex(@SoundexSezione) or @SoundexSezione is null) 
	ORDER BY	
		Prestazioni.SezionePosizione, Prestazioni.PrestazionePosizione, 
		Referti.DataReferto Desc, Referti.NumeroReferto Desc

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiStoricoDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

