


CREATE PROCEDURE [ws3].[RefertoPrestazioniById]
(
	@IdReferti  uniqueidentifier
)
AS
BEGIN

/*
	CREATA DA ETTORE 2016-03-22
		Restituisce TUTTI le PRESTAZIONI associate al referto @IdReferti
		Questa SP dev essere utilizzata solo per ricavare il dettaglio del referto
		Il controllo di accesso deve essere fatto sul record del referto per questo motivo non c'è il parametro @IdToken
*/
	SET NOCOUNT ON

	SELECT	
		Id
		, IdRefertiBase
		, IdEsterno
		, DataErogazione
		--
		, PrestazioneCodice
		, PrestazioneDescrizione
		--
		, PrestazionePosizione		
		--
		, SezioneCodice
		, SezioneDescrizione
		--
		, SezionePosizione
		--
		, GravitaCodice
		, GravitaDescrizione
		--
		, Risultato
		--, RisultatoNumerico -- NON SO COSA SIA
		, ValoriRiferimento
		, Commenti
		--Forse bisognerebbe aggiungere questi campi allo schema di output:
		, Quantita
		, UnitaDiMisura
		, RangeValoreMinimo
		, RangeValoreMassimo
		, RangeValoreMinimoUnitaDiMisura
		, RangeValoreMassimoUnitaDiMisura
		-------------------------------------------------------
	FROM	
		store.Prestazioni
	WHERE	
		IdRefertiBase = @IdReferti

END