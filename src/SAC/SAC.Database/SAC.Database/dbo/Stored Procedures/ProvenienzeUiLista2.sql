





-- =============================================
-- Author:      ETTORE
-- Create date: 2020-04-09
-- Description: Restituisce la lista delle provenienze (da usare nella pagia di lista delle provenienze)
-- =============================================
CREATE PROCEDURE [dbo].[ProvenienzeUiLista2]
(
	@Provenienza AS VARCHAR(16) = ''
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @Provenienza IS NULL SET @Provenienza = ''
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT     
		Provenienza
	  , Descrizione
	  , EmailResponsabile
	  , FusioneAutomatica
	  , DisabilitaRicercaWS
	  , SoloPropriWs
	FROM         
		dbo.Provenienze
	WHERE 
		Provenienza LIKE @Provenienza + '%'

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ProvenienzeUiLista2] TO [DataAccessUi]
    AS [dbo];

