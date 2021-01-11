


CREATE PROCEDURE [dbo].[PazientiWsSinonimiByIdPaziente]
(
	@Identity varchar(64),
	@IdPaziente uniqueidentifier
)
AS
BEGIN
/*
	Modifica Ettore 2014-05-15: modificato il nome della vista PazientiSinonimiOutputResult in PazientiSinonimiSpResult
*/

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiSinonimiByIdPaziente', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiSinonimiByIdPaziente!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	-- La subquery ha lo scopo di ritornare un set di dati univoco dato che la join con la tabella pazienti
	-- potrebbe, se esistono pazienti aventi provenienza ed idprovenienza uguali nello stato fuso, duplicare i dati
	SELECT 
		Q.IdPaziente, Q.Provenienza, Q.IdProvenienza
	FROM (
		SELECT 
			  O.IdPaziente
			, O.Provenienza
			, O.IdProvenienza
			, MAX(P.DataDisattivazione) AS DataDisattivazione
			
		FROM
			dbo.PazientiSinonimiSpResult O
			
			INNER JOIN Pazienti P ON O.Provenienza = P.Provenienza AND O.IdProvenienza = P.IdProvenienza
		
		WHERE     
				O.IdPaziente = @IdPaziente
			AND O.Abilitato = 1
			AND P.Disattivato = 2
			
		GROUP BY 
			O.IdPaziente, O.Provenienza, O.IdProvenienza		
	) AS Q
	
	ORDER BY 
		Q.DataDisattivazione DESC	
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsSinonimiByIdPaziente] TO [DataAccessWs]
    AS [dbo];

