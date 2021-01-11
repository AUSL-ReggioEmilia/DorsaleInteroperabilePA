
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-06
-- Description:	Ritorna la lista dei Gruppi (recursivi) di un utente di AD
-- =============================================
CREATE FUNCTION [organigramma].[OttieneGruppiPerUtente]
(
	@Utente varchar(128)
)
RETURNS @Result TABLE (IdPadre UNIQUEIDENTIFIER NOT NULL
						, IdFiglio UNIQUEIDENTIFIER NOT NULL
						, Livello INT NOT NULL 
						, UtentePadre VARCHAR(128) NULL
						, UtenteFiglio VARCHAR(128) NULL
					  ) 
AS
BEGIN

	WITH UtenteGruppiAll(IdPadre, IdFiglio, Livello, UtentePadre, UtenteFiglio) AS 
	(
	--ANCOR - Profilo selezionato
		SELECT UtentiGruppi.IdUtente AS IdPadre
			, UtentiGruppi.IdGruppo AS IdFiglio
			, 0 AS Livello
			, Utenti.Utente AS UtentePadre
			, Gruppi.Utente AS UtenteFiglio
		FROM organigramma.OggettiActiveDirectoryUtentiGruppi UtentiGruppi
			INNER JOIN organigramma.OggettiActiveDirectory Gruppi ON Gruppi.ID = UtentiGruppi.IdGruppo AND Gruppi.Attivo = 1
			INNER JOIN organigramma.OggettiActiveDirectory Utenti ON Utenti.ID = UtentiGruppi.IdUtente AND Utenti.Attivo = 1
		WHERE Utenti.Utente  = @Utente
			AND Utenti.Tipo = 'Utente'
			AND Utenti.Attivo = 1

		UNION ALL
	--RECUR - Prestazioni e profili figli
		SELECT UtentiGruppi.IdUtente AS IdPadre
			, UtentiGruppi.IdGruppo AS IdFiglio
			, Livello + 1 AS Livello
			, Utenti.Utente AS UtentePadre
			, Gruppi.Utente AS UtenteFiglio
		FROM organigramma.OggettiActiveDirectoryUtentiGruppi UtentiGruppi
			INNER JOIN UtenteGruppiAll ON UtenteGruppiAll.IDFiglio = UtentiGruppi.IdUtente
			INNER JOIN organigramma.OggettiActiveDirectory Gruppi ON Gruppi.Id = UtentiGruppi.IdGruppo AND Gruppi.Attivo = 1
			INNER JOIN organigramma.OggettiActiveDirectory Utenti ON Utenti.ID = UtentiGruppi.IdUtente AND Utenti.Attivo = 1
		-- Evita recursione infinita
		WHERE NOT EXISTS (SELECT * FROM organigramma.OggettiActiveDirectoryUtentiGruppi ug
							WHERE ug.IdUtente = UtenteGruppiAll.IdFiglio
								AND ug.IdGruppo = UtenteGruppiAll.IdPadre)
	)

	INSERT INTO @Result
		SELECT DISTINCT IdPadre, IdFiglio, Livello, UtentePadre, UtenteFiglio
		FROM UtenteGruppiAll
		ORDER BY Livello, UtentePadre

	RETURN 
END

