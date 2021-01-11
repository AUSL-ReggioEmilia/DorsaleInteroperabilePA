-- =============================================
-- Author:		Alessandro Nostini
-- Create date: <Create Date,,>
-- Modify date: 2016-05-11 ETTORE 2012-09-20: traslazione dell'Id paziente nell'attivo
-- Modify date: 2016-05-11 sandro - Usa nuova Func
-- Description:	Ritorna gli attributi del referto con l'ID passato
-- =============================================
CREATE PROCEDURE [dbo].[PazienteDettaglioXml]
	@ID AS uniqueidentifier
AS
BEGIN

	IF NOT @ID IS NULL
	BEGIN
		SELECT @Id = dbo.GetPazienteAttivoByIdSac(@Id)
		--
		-- Solo per i dati
		--
		SELECT Paziente.Id, Paziente.AziendaErogante,
			Paziente.SistemaErogante, Paziente.RepartoErogante, 
			Paziente.Cognome, Paziente.Nome, Paziente.Sesso,
			Paziente.DataNascita, Paziente.LuogoNascita,
			Paziente.CodiceFiscale, Paziente.CodiceSanitario, 
			Attributo.Nome, Attributo.Valore
		FROM dbo.Pazienti AS Paziente 
			CROSS APPLY [OttienePazienteAttributiPerIdSac](Paziente.Id) Attributo
		WHERE Paziente.Id = @ID
		FOR XML AUTO, ELEMENTS

	END ELSE BEGIN
		--
		-- Solo per lo schema
		--
		SELECT Paziente.Id, Paziente.AziendaErogante,
			Paziente.SistemaErogante, Paziente.RepartoErogante, 
			Paziente.Cognome, Paziente.Nome, Paziente.Sesso,
			Paziente.DataNascita, Paziente.LuogoNascita,
			Paziente.CodiceFiscale, Paziente.CodiceSanitario, 
			Attributo.Nome, Attributo.Valore
		FROM dbo.Pazienti AS Paziente
			CROSS APPLY [OttienePazienteAttributiPerIdSac](Paziente.Id) Attributo
		WHERE 1=2
		FOR XML AUTO, ELEMENTS, XMLDATA
	END
END
