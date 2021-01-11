CREATE PROCEDURE [dbo].[BevsSistemiErogantiLista]
(
	@AziendaErogante varchar(16)
	, @Tipo varchar(10)=NULL --@Tipo='referti', 'ricoveri'
)
AS
BEGIN 
	SET NOCOUNT ON;
	SELECT 
		SistemaErogante AS Codice
		,Descrizione
	FROM 
		SistemiEroganti 
	WHERE
		SistemiEroganti.AziendaErogante = @AziendaErogante 
		AND 
			(
				(SistemiEroganti.TipoReferti = 1 AND @Tipo = 'referti')
				OR
				(SistemiEroganti.TipoRicoveri = 1 AND @Tipo = 'ricoveri')
				OR
				(@Tipo IS NULL)			
			)
	ORDER BY 
		Descrizione
	SET NOCOUNT OFF;
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiLista] TO [ExecuteFrontEnd]
    AS [dbo];

