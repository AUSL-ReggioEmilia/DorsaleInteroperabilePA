
-- =============================================
-- Author:		Marco Bellini
-- Create date: 2011-02-09
-- Description:	Looukup sugli stati dell'ordine
-- =============================================
CREATE PROCEDURE [dbo].[UiLookupDatiAccessoriValoriDefault]
	@Codice varchar(32) = NULL
AS
BEGIN
	SET NOCOUNT ON;
		
	SELECT [Codice]
		,[Descrizione]
		,[Attivo]
	FROM [DatiAccessoriDefault]

	WHERE (Codice = @Codice or @Codice is null)
		and attivo = 1
	order by Codice
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiLookupDatiAccessoriValoriDefault] TO [DataAccessUi]
    AS [dbo];

