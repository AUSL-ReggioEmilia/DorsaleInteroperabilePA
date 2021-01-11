
CREATE VIEW [sole_admin].[AbilitazioniSistemiEroganti] AS
	SELECT DISTINCT TOP 1000 SistemaErogante 
	FROM [sole].[AbilitazioniSistemi]
	ORDER BY SistemaErogante
GO
GRANT SELECT
    ON OBJECT::[sole_admin].[AbilitazioniSistemiEroganti] TO [DataAccess_Admin]
    AS [dbo];

