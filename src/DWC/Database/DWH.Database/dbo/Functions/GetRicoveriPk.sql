


-- =============================================
-- Author:		ETTORE
-- Create date: 2018-07-13
-- Description:	Restituisce la coppia di KEY Id + DataPartizione (+ DataModificaEsterno)
-- =============================================
CREATE FUNCTION [dbo].[GetRicoveriPk] 
(
	@IdEsterno AS varchar(64)
)  
RETURNS TABLE 
AS
RETURN 
(
	--
	-- Per effetto del partizionamento non esiste una vera UNIQUE su IdEsterno
	-- per cui ritornerà l'ultimo in ordine di DataPartizione
	--
	SELECT TOP 1 ID, DataPartizione, DataModificaEsterno
	FROM [store].[RicoveriBase]  WITH(NOLOCK)
		WHERE IDEsterno = RTRIM(@IdEsterno)
		ORDER BY DataPartizione DESC
)