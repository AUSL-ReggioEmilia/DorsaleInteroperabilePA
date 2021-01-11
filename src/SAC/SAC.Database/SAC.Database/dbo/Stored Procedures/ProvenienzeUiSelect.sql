


-- =============================================
-- Author:      
-- Create date: 
-- Description: Restituisce un record di dbo.Provenienze
-- Modify date: 2016-08-11 Stefano P: Aggiunto campo FusioneAutomatica
-- Modify date: 2020-02-03 ETTORE: Aggiunto campo "DisabilitaRicercaWS" [ASMN 7700]
-- Modify date: 2020-04-09 ETTORE: Aggiunto campo "SoloPropriWS" [ASMN 8017]
-- =============================================
CREATE PROCEDURE [dbo].[ProvenienzeUiSelect]
   @Provenienza AS varchar(16)	
AS
BEGIN

	SET NOCOUNT ON;

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
		Provenienza = @Provenienza

END











GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ProvenienzeUiSelect] TO [DataAccessUi]
    AS [dbo];

