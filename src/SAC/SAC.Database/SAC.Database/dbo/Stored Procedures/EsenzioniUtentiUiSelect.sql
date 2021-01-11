


-- =============================================
-- Author:		simone B
-- Create date: 2018-03-26
-- Description:	Restituisce un record di "dbo.EsenzioniUtenti"
-- =============================================
CREATE PROCEDURE [dbo].[EsenzioniUtentiUiSelect]
   @Id AS uniqueidentifier
	
AS
BEGIN

	SET NOCOUNT ON;

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT
		Id
	  , Utente
	  , Provenienza
	  , Lettura
	  , Scrittura
	  , Cancellazione
	  , LivelloAttendibilita
	  , Disattivato
	FROM         
		dbo.EsenzioniUtenti

	WHERE
		Id = @Id

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[EsenzioniUtentiUiSelect] TO [DataAccessUi]
    AS [dbo];

