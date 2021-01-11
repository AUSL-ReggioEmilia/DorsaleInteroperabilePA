
CREATE VIEW [sole_admin].[AbilitazioniTipologieSole] AS
	SELECT DISTINCT TOP 1000 TipologiaSole 
	FROM [sole].[AbilitazioniSistemi]
	ORDER BY TipologiaSole
GO
GRANT SELECT
    ON OBJECT::[sole_admin].[AbilitazioniTipologieSole] TO [DataAccess_Admin]
    AS [dbo];

