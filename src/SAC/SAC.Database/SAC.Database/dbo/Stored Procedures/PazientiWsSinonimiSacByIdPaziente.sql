

CREATE PROCEDURE [dbo].[PazientiWsSinonimiSacByIdPaziente]
(
	@Identity varchar(64),
	@IdPaziente uniqueidentifier
)
AS
BEGIN

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsSinonimiSacByIdPaziente', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiWsSinonimiSacByIdPaziente!', 16, 1)
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
			, CAST('SAC' AS VARCHAR(16)) AS Provenienza 
			, UPPER(CAST(O.IdPazienteFuso AS VARCHAR(64))) AS IdProvenienza
			, MAX(P.DataDisattivazione) AS DataDisattivazione
		FROM
			dbo.PazientiFusioni O
			INNER JOIN Pazienti P ON O.IdPazienteFuso = P.Id
		
		WHERE     
				O.IdPaziente = @IdPaziente
			AND O.Abilitato = 1
			AND P.Disattivato = 2
			
		GROUP BY 
			O.IdPaziente, O.IdPazienteFuso
	) AS Q

	ORDER BY 
		Q.DataDisattivazione DESC	
	
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsSinonimiSacByIdPaziente] TO [DataAccessWs]
    AS [dbo];

