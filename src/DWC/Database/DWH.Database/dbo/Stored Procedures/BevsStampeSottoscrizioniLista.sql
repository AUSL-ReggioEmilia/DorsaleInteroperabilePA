


-- =============================================
-- Author:		Ettore
-- Create date: 2013-04-17
-- Description:	Lista sottoscrizioni alle stampe per reparto richiedente
-- Modify date: 2017-01-09:	Aggiunto la restituzione del campo NumeroCopie
-- =============================================
CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniLista]
(
	@Nome VARCHAR(128)
	, @Account VARCHAR(128) = NULL		--L'utente associato alla sottoscrizione
	, @DataFineAl AS DATETIME	= NULL		
	, @IdTipoReferti AS INTEGER = NULL	
	, @ServerDiStampa AS VARCHAR(64) = NULL
	, @Stampante AS VARCHAR(64) = NULL
	, @IdStato AS INTEGER = NULL			
	, @IdTipoSottoscrizione AS INTEGER = NULL	--0=USER, 1=ADMIN
) WITH RECOMPILE
AS
BEGIN
/*
	MODIFICA ETTORE 2015-07-02: Restituito i nuovi campi campi StampaConfidenziali e StampaOscurati
	MODIFICA ETTORE 2017-01-09: Restituito il campo NumeroCopie
*/
/*
	@Account		=> L'utente associato alla sottoscrizione
	@TipoReferti	=> Tipo referti da stampare: 0=TUTTI, 1=DEFINITIVI 2=DEFINITIVI CON PDF/FIRMATI
	@Stato			=> Stato della sottoscrizione: 1=ATTIVA, 2=RICHIESTA DISATTIVAZIONE, 3=DISATTIVA, 4=TIMEOUT(SCADUTA)
	@TipoSottoscrizione => Identifica se la sottoscrizione è stata creata da FE USER o FE ADMIN: 0=USER, 1=ADMIN (ORA E' SOLO FE ADMIN)
*/
	SET NOCOUNT ON;
	
	IF NOT @DataFineAl IS NULL 
		SET @DataFineAl = DATEADD(day,1,@DataFineAl)
		
	SELECT StampeSottoscrizioni.Id
		,StampeSottoscrizioni.DataInserimento
		,StampeSottoscrizioni.DataModifica
		,StampeSottoscrizioni.Account
		,StampeSottoscrizioni.DataInizio
		,StampeSottoscrizioni.DataFine
		,StampeSottoscrizioni.TipoReferti AS IdTipoReferti
		,StampeSottoscrizioniTipoReferti.Descrizione AS TipoReferti
		,REPLACE(StampeSottoscrizioni.ServerDiStampa , '\', '') AS ServerDiStampa
		,StampeSottoscrizioni.Stampante
		,StampeSottoscrizioni.Stato AS IdStato
		,StampeSottoscrizioniStati.Descrizione AS Stato
		,StampeSottoscrizioniTipoSottoscrizioni.Descrizione AS TipoSottoscrizione
		,StampeSottoscrizioni.Nome
		,StampeSottoscrizioni.Descrizione 
		,StampeSottoscrizioni.Ts
		,StampaConfidenziali 
		,StampaOscurati
		,NumeroCopie
	FROM 
		StampeSottoscrizioni 
		inner join StampeSottoscrizioniStati 
			on StampeSottoscrizioniStati.Id = Stato
		inner join StampeSottoscrizioniTipoSottoscrizioni 
			on StampeSottoscrizioniTipoSottoscrizioni.Id = TipoSottoscrizione
		inner join StampeSottoscrizioniTipoReferti 
			on StampeSottoscrizioniTipoReferti.Id = TipoReferti
	WHERE
		(@Account IS NULL or Account like '%' + @Account + '%')
		AND	(@DataFineAl IS NULL or DataFine <= @DataFineAl)
		AND (@ServerDiStampa IS NULL or ServerDiStampa like '%' + @ServerDiStampa + '%')
		AND (@Stampante IS NULL OR Stampante like '%' + @Stampante + '%')
		AND (@IdStato IS NULL OR Stato = @IdStato)
		AND (@IdTipoSottoscrizione IS NULL OR TipoSottoscrizione = @IdTipoSottoscrizione )
		AND (@IdTipoReferti IS NULL OR TipoReferti = @IdTipoReferti)
		AND (@Nome IS NULL OR Nome like '%' +  @Nome + '%')

END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniLista] TO [ExecuteFrontEnd]
    AS [dbo];

