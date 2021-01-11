
--
-- Ritorna > 0 se il la Prestazione/Profilo è già nel Profilo
--
CREATE FUNCTION [dbo].[IsProfiloNelProfiloRecursivo](
	@IdProfiloPadre AS UNIQUEIDENTIFIER
	,@IdProfiloFiglio AS UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0;
	
	WITH PrestazioniProfiliAll(IDPadre, IDFiglio, Livello) AS 
	(
	--ANCOR - Profilo selezionato
		SELECT pp.IDPadre
			, pp.IDFiglio
			, 0 AS Livello
		FROM PrestazioniProfili pp
			INNER JOIN Prestazioni p ON pp.IDPadre = p.ID
		WHERE pp.IDPadre = @IdProfiloPadre

		UNION ALL
	--RECUR - Prestazioni e profili figli
		SELECT pp.IDPadre
			, pp.IDFiglio
			, Livello + 1
		FROM PrestazioniProfili pp
			INNER JOIN PrestazioniProfiliAll AS ppa
				ON ppa.IDFiglio = pp.IDPadre
	)
		
	--Tutti i figli prestazioni a qualsiasi livello
	SELECT @Ret = COUNT(*)
	FROM PrestazioniProfiliAll ppa
		INNER JOIN Prestazioni pf ON ppa.IDFiglio = pf.ID
	WHERE pf.Tipo <> 0
		AND ppa.IDFiglio = @IdProfiloFiglio
			
	RETURN @Ret	
END
