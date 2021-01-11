
CREATE PROCEDURE [dbo].[SrvcStampeRefertiJobName]
(
	@IdReferto uniqueidentifier
)
AS
BEGIN
/*

	MODIFICA ETTORE 2015-07-02:
		Uso la vista store.Referti poichè la SP viene chiamata dal servizio con un IdReferto processabile

*/
	SET NOCOUNT ON

	SELECT 
		CAST(AziendaErogante + '-' + SistemaErogante + '-' + NumeroReferto AS VARCHAR(256))  AS JobName
	FROM 
		store.Referti
	WHERE 
		Id = @IdReferto

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeRefertiJobName] TO [ExecuteService]
    AS [dbo];

