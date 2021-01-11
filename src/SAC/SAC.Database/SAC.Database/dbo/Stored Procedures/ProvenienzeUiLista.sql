



-- =============================================
-- Author:      
-- Create date: 
-- Description: Restituisce la lista delle provenienze
-- Modify date: 2020-02-03 ETTORE: Aggiunto campo "DisabilitaRicercaWS" [ASMN 7700] e campo già esistente "FusioneAutomatica"
-- Modify date: 2020-04-09 ETTORE: Aggiunto campo "SoloPropriWS" [ASMN 8017]
-- ATTENZIONE: questa SP è stata utilizzata per caricare le combo delle provenienze e non può essere modificata per aggiungere un parametro di filtro
-- =============================================
CREATE PROCEDURE [dbo].[ProvenienzeUiLista]
	
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

END















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ProvenienzeUiLista] TO [DataAccessUi]
    AS [dbo];

