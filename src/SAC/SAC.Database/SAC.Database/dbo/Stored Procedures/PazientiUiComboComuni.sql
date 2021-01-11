CREATE PROCEDURE [dbo].[PazientiUiComboComuni]
(
	@CodiceProvincia as varchar(3) = null
)
AS
BEGIN
/*
	MODIFICA ETTORE 2014-05-20: 
		tolto i campi Obsoleto e ObsoletoData (li restituisco usando i nuovi campi)
	MODIFICA ETTORE 2014-07-16:
		Nel caso @CodiceProvincia identifichi un valore che corrispone a "Codice sconosciuto"
		restituisco solo il codice comune '000000', il valore che deve essere salvato nel database
*/
	SET NOCOUNT ON;
	--
	-- MODIFICA ETTORE 2014-07-16: se @CodiceProvincia identifica "Codice sconosciuto" 
	--	
	IF (ISNULL(@CodiceProvincia,'') = '' OR @CodiceProvincia = '-1')
		SET @CodiceProvincia = '000' --Codice provincia impossibile
	--
	--  Restituisco i dati
	--
	IF (@CodiceProvincia = '000')
	BEGIN 
		--
		-- MODIFICA ETTORE 2014-07-16: Restituisco "Codice comune sconosciuto"
		--
		SELECT 
			  '000000' AS Codice	--Il valore da salvare nel database
			, '{Comune sconosciuto}' AS Nome
	END
	ELSE
	BEGIN
		SELECT 
			  Codice
			, CASE
				WHEN NOT (GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE())) AND (DataFineValidita IS NULL) THEN
					Nome + ' (Obsoleto)'
				WHEN NOT (GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE())) AND NOT (DataFineValidita IS NULL) THEN 
					Nome + ' (Fino al ' + CONVERT(VARCHAR(10) , DataFineValidita, 103 ) + ')'
				ELSE Nome
			END AS Nome
		FROM 
			IstatComuni
		WHERE 
			(CodiceProvincia = @CodiceProvincia) OR (ISNULL(@CodiceProvincia, 0) = 0)
		ORDER BY 
			Nome
	END
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiComboComuni] TO [DataAccessUi]
    AS [dbo];

