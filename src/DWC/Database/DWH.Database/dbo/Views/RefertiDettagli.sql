

/*
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/
CREATE VIEW [dbo].[RefertiDettagli]
AS
	SELECT	Attributo.IdRefertiBase, 
			Attributo.Nome AS NomeAttributo,
			Attributo.Valore AS ValoreAttributo

	FROM	store.Referti
		INNER JOIN store.RefertiAttributi Attributo WITH(NOLOCK)
			ON Referti.Id = Attributo.IdRefertiBase

GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiDettagli] TO [ExecuteFrontEnd]
    AS [dbo];

