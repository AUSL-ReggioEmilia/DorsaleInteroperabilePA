
CREATE VIEW [sole_admin].[AbilitazioniTipiEroganti] AS
	SELECT DISTINCT TOP 1000 TipoErogante 
	FROM [sole].[AbilitazioniSistemi]
	ORDER BY TipoErogante
GO
GRANT SELECT
    ON OBJECT::[sole_admin].[AbilitazioniTipiEroganti] TO [DataAccess_Admin]
    AS [dbo];

