CREATE PROCEDURE [dbo].[FeprTracciaAccessiSommario]
AS
BEGIN
	/*
	Ritorna la lista degli accessi forzati
	*/
	SET NOCOUNT ON

	SELECT	CONVERT( VARCHAR(7), TracciaAccessi.Data, 120 ) AS AnnoMese,
			COUNT(*) AS Numero,
			COALESCE( TracciaAccessi.NomeRichiedente, TracciaAccessi.UtenteRichiedente) AS OperatoreNome
	FROM	
		(
			SELECT Id, Data, UtenteRichiedente, NomeRichiedente, Operazione FROM TracciaAccessi
			UNION 
			SELECT Id, Data, UtenteRichiedente, NomeRichiedente, Operazione FROM TracciaAccessi_Storico
		) AS TracciaAccessi

	WHERE 
		TracciaAccessi.Data > DATEADD(month, -5, GETDATE())
		AND	(TracciaAccessi.Operazione = 'Apre referto' OR TracciaAccessi.Operazione = 'Lista referti')

	GROUP BY	CONVERT( VARCHAR(7), TracciaAccessi.Data, 120 ),
				COALESCE( TracciaAccessi.NomeRichiedente, TracciaAccessi.UtenteRichiedente)
	ORDER BY	CONVERT( VARCHAR(7), TracciaAccessi.Data, 120 ) DESC,
				COALESCE( TracciaAccessi.NomeRichiedente, TracciaAccessi.UtenteRichiedente)

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprTracciaAccessiSommario] TO [ExecuteFrontEnd]
    AS [dbo];

