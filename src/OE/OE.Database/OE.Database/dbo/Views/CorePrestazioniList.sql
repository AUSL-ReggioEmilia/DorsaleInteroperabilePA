
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2014-02-14
-- Description:	Seleziona una lista di prestazioni
--				Usata da tutte le SP CorePrestazioniListByXxxxx
-- =============================================
CREATE VIEW [dbo].[CorePrestazioniList]
AS
		SELECT P.ID
			, P.Codice, P.Descrizione, P.Tipo, P.Provenienza, P.IDSistemaErogante
			, S.CodiceAzienda AS CodiceAzienda, A.Descrizione AS DescrizioneAzienda
			, S.Codice AS CodiceSistema, S.Descrizione AS DescrizioneSistema
		FROM Prestazioni P
			INNER JOIN Sistemi S ON P.IDSistemaErogante = S.ID
			INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda
		WHERE P.Attivo = 1
			AND (S.Attivo = 1 OR S.ID = '00000000-0000-0000-0000-000000000000')
