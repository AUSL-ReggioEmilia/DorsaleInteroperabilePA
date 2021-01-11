-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-02-27
-- Modify date: 2016-05-03 Sandro: Usa SistemiEstesa per limitaare le Query Distribuite
-- Description:	Esplode la gerarchia di un profili
-- =============================================
CREATE FUNCTION [dbo].[GetProfiloGerarchia2]
(
	@idProfilo uniqueidentifier
)
RETURNS @Result TABLE (IDPadre UNIQUEIDENTIFIER NOT NULL
						, IDFiglio UNIQUEIDENTIFIER NOT NULL
						, Livello INT NOT NULL 
						, IdSistemaErogante UNIQUEIDENTIFIER NULL 
						, Tipo INT NOT NULL 
						, Attivo Bit NOT NULL) 
AS
BEGIN

	WITH PrestazioniProfiliAll(IDPadre, IDFiglio, Livello, IdSistemaErogante, Tipo, Attivo) AS 
	(
	--ANCOR - Profilo selezionato
		SELECT pp.IDPadre
			, pp.IDFiglio
			, 0 AS Livello
			, pf.IdSistemaErogante AS IdSistemaErogante
			, pf.Tipo AS Tipo
			, pf.Attivo AS Attivo
		FROM PrestazioniProfili pp
			INNER JOIN Prestazioni p ON pp.IDPadre = p.ID
			INNER JOIN Prestazioni pf ON pp.IDFiglio = pf.ID

		WHERE pp.IDPadre = @idProfilo

		UNION ALL
	--RECUR - Prestazioni e profili figli
		SELECT pp.IDPadre
			, pp.IDFiglio
			, Livello + 1
			, pf.IdSistemaErogante AS IdSistemaErogante
			, pf.Tipo AS Tipo
			, pf.Attivo AS Attivo
		FROM PrestazioniProfili pp
			INNER JOIN PrestazioniProfiliAll AS ppa	ON ppa.IDFiglio = pp.IDPadre
			INNER JOIN Prestazioni pf ON pp.IDFiglio = pf.ID
	)

	INSERT INTO @Result
		SELECT PP.IDPadre, PP.IDFiglio, PP.Livello
				, PP.IdSistemaErogante, PP.Tipo
				-- And Attivo su prestazioni e Sistema
				, CASE WHEN PP.Attivo = 1 THEN
						CASE WHEN SE.Attivo = 1 OR SE.ID = '00000000-0000-0000-0000-000000000000' THEN 1 ELSE 0 END
					ELSE 0 END Attivo
		FROM PrestazioniProfiliAll PP

			-- 2016-05-03 Usa SistemiEstesa per limitaare le Query Distribuite
			INNER JOIN SistemiEstesa SE ON SE.ID = PP.IdSistemaErogante

	RETURN 
END
