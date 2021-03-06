﻿


-- =============================================
-- Author:		ETTORE 
-- Create date: 2016-03-24
-- Description:	Questa deve restituire i dati che servono nella visualizzazione del "PANNELLO PAZIENTE SAC":
-- Modify date: 2017-11-21 ETTORE: Aggiunto i campi di anteprima delle note anamnestiche
-- =============================================
CREATE PROCEDURE [ws3].[PazienteById]
(
	@IdPaziente  uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON
	--			
	-- Traslo l'idpaziente nell'idpaziente attivo			
	--
	SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
	--
	-- Imposto una data minima di accettazione per la ricerca delle info ricoveri e ricavo la relativa data minima di partizione
	--
	DECLARE @DataMinimaAccettazione DATETIME
	SET @DataMinimaAccettazione = DATEADD(day, - 2555, GETDATE()) --7 anni
	DECLARE @DataMinimaPartizione DATETIME
	SET @DataMinimaPartizione = dbo.OttieniFiltroRicoveriPerDataPartizione(@DataMinimaAccettazione)
	--
	-- Restituisco i dati
	--
	SELECT	
		Id
		, CodiceAnagraficaErogante
		, NomeAnagraficaErogante
		, Cognome		
		, Nome		
		, CodiceFiscale		
		, DataNascita		
		, Sesso		
		, CodiceSanitario
		, LuogoNascitaCodice 
		, LuogoNascita AS LuogoNascitaDescrizione
		, NazionalitaCodice
		, NazionalitaDescrizione		
		--Dati di domicilio
		, ComuneDomicilioCodice
		, ComuneDomicilioDescrizione
		, DomicilioCap AS ComuneDomicilioCAP
		, DomicilioIndirizzo AS IndirizzoDomicilio
		--Dati di residenza		
		, ComuneResidenzaCodice
		, ComuneResidenzaDescrizione
		, ResidenzaCap AS ComuneResidenzaCAP
		, ResidenzaIndirizzo AS IndirizzoResidenza
		--		
		, DataDecesso
		--		
		-- Dati del consenso aziendale: NULL, 1=Generico, 2=Dossier, 3=DossierStorico
		--
		, ConsensoAziendaleCodice
		, ConsensoAziendaleDescrizione	
		, ConsensoAziendaleData 
		--		
		-- Dati del consenso SOLE:
		--
		, ConsensoSoleCodice		--NULL, 10=SOLE-LIVELLO0,11=SOLE-LIVELLO1,12=SOLE-LIVELLO2
		, ConsensoSoleDescrizione
		, ConsensoSoleData
		--
		-- Prendo i dati di AnteprimaReferti e li scrivo in campi strutturati
		--
		,AR.NumeroReferti
		,AR.UltimoRefertoSistemaErogante
		,AR.UltimoRefertoData
		--Questo viene usato per popolare il nodo Episodio del dettaglio paziente
		,PA.IdUltimoRicovero
		--Informazioni sulle note anamnestiche del paziente
		, PA.NumeroNoteAnamnestiche
		, PA.UltimaNotaAnamnesticaData
		, PA.UltimaNotaAnamnesticaSistemaEroganteDescr
	FROM	
		Pazienti
		LEFT OUTER JOIN dbo.PazientiAnteprima AS PA
			ON PA.IdPaziente = @IdPaziente
		OUTER APPLY dbo.ParseAnteprimaReferti(Pa.AnteprimaReferti) AS AR
	WHERE   
		Id = @IdPaziente

END