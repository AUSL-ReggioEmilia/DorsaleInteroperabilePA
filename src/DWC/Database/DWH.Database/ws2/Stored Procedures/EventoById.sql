
CREATE PROCEDURE [ws2].[EventoById]
(
	@IdEvento  uniqueidentifier
)
AS
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2EventoById
		Restituito il campo XML Oscuramenti

	Restituisce le informazioni relative al referto con l'ID passato
*/
	SET NOCOUNT ON

	SELECT  
		Id,
		AziendaErogante,
		SistemaErogante,
		ISNULL(RepartoErogante,'') AS RepartoErogante, --gestione NULL
		DataEvento,
		TipoEventoCodice,
		TipoEventoDescr,
		NumeroNosologico,
		ISNULL(TipoEpisodio,'') AS TipoEpisodio,--gestione dei null
		TipoEpisodioDescr, --supporta il null
		Cognome,
		Nome,
		CodiceFiscale,
		DataNascita,
		ComuneNascita,
		ISNULL(RepartoCodice,'') AS RepartoCodice, --gestione dei null
		ISNULL(RepartoDescr,'') AS RepartoDescr, --gestione dei null
		Diagnosi,--supporta il null
		--
		-- Restituisco XML col lista degli oscuramenti
		--
		Oscuramenti
	FROM	
		ws2.Eventi
	WHERE	
		Id = @IdEvento

	RETURN @@ERROR
