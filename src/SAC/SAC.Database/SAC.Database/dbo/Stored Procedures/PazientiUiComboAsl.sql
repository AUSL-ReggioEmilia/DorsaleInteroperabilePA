


CREATE PROCEDURE [dbo].[PazientiUiComboAsl]
(
	@CodiceComune as varchar(6)
)
AS
BEGIN
/*
	MODIFICA ETTORE 2014-07-16:
		Nel caso @CodiceComune identifichi un valore che corrispone a "Codice sconosciuto"
		restituisco solo il codice asl '000', il valore che deve essere salvato nel database
	MODIFICA ETTORE 2015-05-24: cerco sempre il codice della regione, perchè nella tabella IstataAsl potrebbe mancare
*/		
	SET NOCOUNT ON;
	--
	-- MODIFICA ETTORE 2014-07-16: se CodiceComune identifica "Codice sconosciuto" 
	--	
	IF (ISNULL(@CodiceComune, '') = '' OR @CodiceComune = '-1')
		SET @CodiceComune = '000000'
	--
	--  Restituisco i dati
	--
	IF (@CodiceComune = '000000')
		BEGIN
			SELECT '000' AS Codice	--Il valore da salvare nel database
			, '{Asl sconosciuta}' AS Nome
		END
	ELSE
	BEGIN
		--
		-- Ricavo dalla tabella IstatComuni il codice della regione
		--
		DECLARE @CodiceAslRegione VARCHAR(3)
		SELECT @CodiceAslRegione = CodiceRegione FROM [IstatComuni] Where Nazione = 0
		AND Codice = @CodiceComune

		--
		-- Eseguo join utilizzando il codice della regione @CodiceAslRegione 
		--
		SELECT DISTINCT
			D.CodiceAsl AS Codice
			, D.DescrizioneAsl AS Nome
		FROM 
			(
			SELECT Codice, 
				CASE WHEN CodiceAslRegione = '' THEN 
					@CodiceAslRegione
				ELSE 
					CodiceAslRegione
				END AS CodiceAslRegione
				FROM IstatAsl
			WHERE (CodiceComune = @CodiceComune)
			) AS IA		
			INNER JOIN DizionarioIstatAsl AS D  
				ON IA.Codice = D.CodiceAsl 
					AND IA.CodiceAslRegione = D.CodiceRegione
		ORDER BY Nome

		--
		-- Se la query precedente nn ha trovato nulla aggiungo un valore di default
		--
		IF @@ROWCOUNT = 0 
		BEGIN
			SELECT 
				'000' AS Codice		--Il valore da salvare nel database
				, '{Asl sconosciuta}' AS Nome
		END

	END
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiComboAsl] TO [DataAccessUi]
    AS [dbo];

