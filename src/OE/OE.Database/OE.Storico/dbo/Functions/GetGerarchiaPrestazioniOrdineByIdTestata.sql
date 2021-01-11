


CREATE FUNCTION [dbo].[GetGerarchiaPrestazioniOrdineByIdTestata]
(
	@idOrdineTestata uniqueidentifier
)
RETURNS @Result TABLE (IDPadre UNIQUEIDENTIFIER NOT NULL, IDFiglio UNIQUEIDENTIFIER NOT NULL, Livello INT NOT NULL) 
AS
BEGIN

	WITH PrestazioniProfiliAll(IDPadre, IDFiglio, Livello) AS 
	(
	--ANCOR - Profilo selezionato
		SELECT pp.IDPadre
			, pp.IDFiglio
			, 0 AS Livello
		FROM PrestazioniProfili pp
			INNER JOIN Prestazioni p ON pp.IDPadre = p.ID
			INNER JOIN OrdiniRigheRichieste rr ON rr.IdPrestazione = pp.IDPadre
			
		WHERE rr.IDOrdineTestata = @idOrdineTestata

		UNION ALL
	--RECUR - Prestazioni e profili figli
		SELECT pp.IDPadre
			, pp.IDFiglio
			, Livello + 1
		FROM PrestazioniProfili pp
			INNER JOIN PrestazioniProfiliAll AS ppa	ON ppa.IDFiglio = pp.IDPadre
	)

	INSERT INTO @Result
		--Prestazioni dei profili
		SELECT IDPadre, IDFiglio
			, Livello + 1 AS Livello
		FROM PrestazioniProfiliAll
	
		UNION
		
		--Prestazione dell'ordine
		SELECT IdPrestazione, IdPrestazione
			, 0 AS Livello
		FROM OrdiniRigheRichieste R
				INNER JOIN Prestazioni p ON R.IDPrestazione = p.ID
		WHERE R.IDOrdineTestata = @idOrdineTestata
				AND p.Tipo = 0
		ORDER BY Livello
	RETURN 
END
