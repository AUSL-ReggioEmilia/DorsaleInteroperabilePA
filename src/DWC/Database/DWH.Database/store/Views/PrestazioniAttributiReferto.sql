
CREATE VIEW [store].[PrestazioniAttributiReferto]
AS
	SELECT	P.IdRefertiBase,
			P.DataPartizione, 
			PA.IdPrestazioniBase, 
			PA.Nome,
			PA.Valore
	FROM dbo.PrestazioniAttributi_History AS PA
		INNER JOIN dbo.PrestazioniBase_History AS P
			ON PA.IdPrestazioniBase = P.Id
				AND PA.DataPartizione = P.DataPartizione
	
	UNION ALL
	
	SELECT	P.IdRefertiBase,
			P.DataPartizione, 
			PA.IdPrestazioniBase, 
			PA.Nome,
			PA.Valore
	FROM dbo.PrestazioniAttributi_Recent AS PA
		INNER JOIN dbo.PrestazioniBase_Recent AS P
			ON PA.IdPrestazioniBase = P.Id
				AND PA.DataPartizione = P.DataPartizione


