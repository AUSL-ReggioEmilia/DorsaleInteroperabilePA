
-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 - ETTORE: usato le viste "store" al posto delle viste "dbo"
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[PrestazioneDettaglio]
(
	@IdRefertiBase AS uniqueidentifier
)
AS
BEGIN 
	SET NOCOUNT ON

	SELECT 
		Attributo.Nome
		, Attributo.Valore
	FROM 
		store.Prestazioni AS Prestazione 
		INNER JOIN store.PrestazioniAttributi AS Attributo
			ON Prestazione.Id =  Attributo.IdPrestazioniBase
	WHERE 
		Prestazione.IdRefertiBase = @IdRefertiBase
	ORDER BY  
		Prestazione.PrestazioneCodice, Attributo.Nome

END
