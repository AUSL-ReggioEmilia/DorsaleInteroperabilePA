


CREATE VIEW [sole_admin].[AbilitazioniAziendeEroganti] AS
	SELECT DISTINCT TOP 1000 AziendaErogante 
	FROM [sole].[AbilitazioniSistemi]
	ORDER BY AziendaErogante
GO
GRANT SELECT
    ON OBJECT::[sole_admin].[AbilitazioniAziendeEroganti] TO [DataAccess_Admin]
    AS [dbo];

