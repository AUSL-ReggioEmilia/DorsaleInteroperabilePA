


-- =============================================
-- Author:		ETTORE
-- Create date: 2015-05-22
-- Description:	Sostituisce la dbo.Ws2RefertoAttributiById
--				Restituisce gli attributi del referto con l'ID passato
--				Utilizza la vista store.RefertiAttributi
-- Modify date: 2020-05-18 - ETTORE: Filtro gli attributi "Persistenti" (iniziano on $@)
--									 Restituisco solo '$@NumeroVersione' con il nome 'Dwh@NumeroVersione'
--									 Aggiunto l'ordinamento per Nome
-- =============================================
CREATE PROCEDURE [ws2].[RefertoAttributiById]
(
	@IdReferti  uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT	
		IdRefertiBase 
		, CASE 
			WHEN Nome = '$@NumeroVersione' THEN 'Dwh@NumeroVersione'
			ELSE Nome END AS Nome
		, Valore
	FROM	
		store.RefertiAttributi
	WHERE	
		IdRefertiBase = @IdReferti
		AND (
			NOT Nome like '$@%'
			OR Nome = '$@NumeroVersione'
			)
	ORDER BY Nome

	RETURN @@ERROR
END
