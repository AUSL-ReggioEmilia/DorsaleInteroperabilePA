

CREATE VIEW [store].[AllegatiAttributiReferto]
AS
	SELECT	P.IdRefertiBase,
			P.DataPartizione, 
			PA.IdAllegatiBase, 
			PA.Nome,
			PA.Valore
	FROM dbo.AllegatiAttributi_History AS PA
		INNER JOIN dbo.AllegatiBase_History AS P
			ON PA.IdAllegatiBase = P.Id
				AND PA.DataPartizione = P.DataPartizione

	UNION ALL
	
	SELECT	P.IdRefertiBase,
			P.DataPartizione, 
			PA.IdAllegatiBase, 
			PA.Nome,
			PA.Valore
	FROM dbo.AllegatiAttributi_Recent AS PA
		INNER JOIN dbo.AllegatiBase_Recent AS P
			ON PA.IdAllegatiBase = P.Id
				AND PA.DataPartizione = P.DataPartizione
