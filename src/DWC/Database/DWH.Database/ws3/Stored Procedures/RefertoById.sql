



-- =============================================
-- Author:		ETTORE
-- Create date: 2016-03-22:
-- Description:	Restituisce i dati di TESTATA referto da usare nel dettaglio di un referto
-- Modify date: 2019-03-22: restituisco lo stato di visibilità del referto: sarà il servizio WEB a generare l'eccezione per segnalare se il referto esiste o non è visibile
-- =============================================
CREATE PROCEDURE [ws3].[RefertoById]
(
	@IdToken UNIQUEIDENTIFIER
	, @IdReferti  uniqueidentifier
)
AS
BEGIN
/*
	CREATA DA ETTORE 2016-03-22:
		Restituisce i dati di TESTATA referto da usare nel dettaglio di un referto

*/
	SET NOCOUNT ON
	--
	-- Verifico se al token è associato l'attibuto ATTRIB@VIEW_ALL
	--
	DECLARE @ViewAll as BIT=0
	IF EXISTS(SELECT * FROM dbo.OttieniRuoliAccessoPerToken(@IdToken) where Accesso = 'ATTRIB@VIEW_ALL')
		SET @ViewAll = 1
	--
	-- Ricavo l'Id del ruolo Role Manager associato al token
	--
	DECLARE @IdRuolo UNIQUEIDENTIFIER 
	SELECT @IdRuolo = IdRuolo FROM dbo.Tokens WHERE Id = @IdToken
	--
	-- Restituisco i dati
	--
	SELECT  
		Id
		, IdEsterno
		, DataInserimento
		, DataModifica
		, AziendaErogante
		, SistemaErogante
		--
		-- RepartoErogante: il codice del reparto erogante non esiste al momento
		--
		, CAST(NULL AS VARCHAR(16)) AS RepartoEroganteCodice
		, RepartoErogante AS RepartoEroganteDescr
		, DataReferto
		, DataEvento
		, NumeroReferto
		, NumeroNosologico
		, NumeroPrenotazione
		, IdOrderEntry 
		, Anteprima
		, SpecialitaErogante 
		, Firmato
		, RepartoRichiedenteCodice
		, RepartoRichiedenteDescr
		, StatoRichiestaCodice
		, StatoRichiestaDescr
		, TipoRichiestaCodice
		, TipoRichiestaDescr
		, PrioritaCodice
		, PrioritaDescr
		, Referto
		, MedicoRefertanteCodice
		, MedicoRefertanteDescr
		-------------------------------------------------
		-- Dati paziente
		-------------------------------------------------
		--Traslo l'Id paziente nell'id paziente attivo
		, dbo.GetPazienteAttivoByIdSac(IdPaziente) AS IdPaziente
		, Cognome
		, Nome
		, CodiceFiscale
		, DataNascita
		, Sesso
		, ComuneNascita
		, CodiceSanitario
		, CASE WHEN (@ViewAll = 1) 
			OR 
			(
				EXISTS( SELECT * FROM [dbo].[OttieniSistemiErogantiPerToken](@IdToken) SE 
						WHERE   Referti.SistemaErogante = SE.SistemaErogante AND  Referti.AziendaErogante = SE.AziendaErogante)
				AND 
				([dbo].[CheckRefertoOscuramenti] (@IdRuolo, Referti.Id, Referti.DataPartizione, Referti.AziendaErogante, Referti.SistemaErogante
												, Referti.StrutturaEroganteCodice, Referti.NumeroNosologico, Referti.RepartoRichiedenteCodice
												, Referti.RepartoErogante, Referti.Confidenziale ) = 1)
			)
			THEN	
				CAST(1 AS BIT)  
			ELSE
				CAST(0 AS BIT)
			END 
			AS RefertoVisibile 
	FROM	
		ws3.Referti
	WHERE	
		--
		-- Filtro per Sistema e Oscuramenti
		--
		--(
		--	(@ViewAll = 1) 
		--	OR 
		--	(
		--		EXISTS( SELECT * FROM [dbo].[OttieniSistemiErogantiPerToken](@IdToken) SE 
		--				WHERE   Referti.SistemaErogante = SE.SistemaErogante AND  Referti.AziendaErogante = SE.AziendaErogante)
		--		AND 
		--		([dbo].[CheckRefertoOscuramenti] (@IdRuolo, Referti.Id, Referti.DataPartizione, Referti.AziendaErogante, Referti.SistemaErogante
		--										, Referti.StrutturaEroganteCodice, Referti.NumeroNosologico, Referti.RepartoRichiedenteCodice
		--										, Referti.RepartoErogante, Referti.Confidenziale ) = 1)
		--	)
		--) 		
		--AND 
		Id = @IdReferti

END