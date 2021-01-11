
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2014-02-14
-- Modify date: 2014-09-24 - Ritorna solo gli attivi
-- Modify date: 2018-06-27 - Aggiunto campo RichiedibileSoloDaProfilo
--
-- Description:	Seleziona una lista di prestazioni
--				Usata da tutte le SP CorePrestazioniSelectByXxxxx
--				Nasconde le prestazioni non attive
-- =============================================
CREATE VIEW [dbo].[CorePrestazioniSelect]
AS
	SELECT    P.ID
			, P.Codice
			, P.Descrizione
			, P.Tipo
			, P.Provenienza
			, P.IDSistemaErogante
			, S.CodiceAzienda AS CodiceAziendaSistemaErogante
			, A.Descrizione AS DescrizioneAziendaSistemaErogante
			, S.Codice AS CodiceSistemaErogante
			, S.Descrizione AS DescrizioneSistemaErogante
			, P.CodiceSinonimo
			, P.RichiedibileSoloDaProfilo
	FROM Prestazioni P
		INNER JOIN Sistemi S ON S.ID = P.IDSistemaErogante
		INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda
	WHERE P.Attivo = 1 --AND S.Attivo = 1
