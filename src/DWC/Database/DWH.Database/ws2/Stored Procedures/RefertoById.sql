
CREATE PROCEDURE [ws2].[RefertoById]
(
	@IdReferti  uniqueidentifier
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RefertoById
		Restituito il campo XML Oscuramenti

	Restituisce le informazioni relative al referto con l'ID passato
	Restituisco i campi DataEvento e Firmato
	
*/
	SET NOCOUNT ON

	SELECT  Id,
			--Traslo l'Id paziente nell'id paziente attivo
			dbo.GetPazienteAttivoByIdSac(IdPaziente) AS IdPaziente,
			DataInserimento,
			DataModifica,
			AziendaErogante,
			SistemaErogante,
			RepartoErogante,
			DataReferto,
			NumeroReferto,
			NumeroNosologico,
			NumeroPrenotazione,
			Cognome,
			Nome,
			Sesso,
			CodiceFiscale,
			DataNascita,
			ComuneNascita,
			---------- Li restituisco per compatibilità
			CAST(NULL AS VARCHAR(4)) AS ProvinciaNascita,
			CAST(NULL AS VARCHAR(64)) AS ComuneResidenza,
			CAST(NULL AS VARCHAR(64)) AS CodiceSAUB,
			-----------------------------------------------			
			CodiceSanitario,
			RepartoRichiedenteCodice,
			RepartoRichiedenteDescr,
			StatoRichiestaCodice,
			StatoRichiestaDescr,
			TipoRichiestaCodice,
			TipoRichiestaDescr,
			PrioritaCodice,
			PrioritaDescr,
			Referto,
			MedicoRefertanteCodice,
			MedicoRefertanteDescr,
			DataEvento,
			Firmato,
			--
			-- Restituisco XML col lista degli oscuramenti
			--
			Oscuramenti
	FROM	
		ws2.Referti
	WHERE	
		Id = @IdReferti

	RETURN @@ERROR
	
END 

