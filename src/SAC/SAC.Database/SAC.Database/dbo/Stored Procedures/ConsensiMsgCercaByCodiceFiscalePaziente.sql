

-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Aggancia il paziente per codice fiscale
-- Modifiy date: 2019-01-14 - ETTORE: non aggancio se @PazienteCodiceFiscale = 0000000000000000
-- =============================================
CREATE PROCEDURE [dbo].[ConsensiMsgCercaByCodiceFiscalePaziente]
	  @PazienteCodiceFiscale varchar(16)
	, @Utente AS varchar(64)

AS
BEGIN

DECLARE @PazienteId AS uniqueidentifier
DECLARE @Msg AS varchar(255)

	SET NOCOUNT ON;
	
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	
	IF dbo.LeggeConsensiPermessiLettura(@Utente) = 0
		BEGIN
			EXEC PazientiEventiAccessoNegato @Utente, 0, 'ConsensiMsgCercaPazienteByCodiceFiscale', 'Utente non ha i permessi di lettura!'

			RAISERROR('Errore di controllo accessi!', 16, 1)
			RETURN 1002
		END

	---------------------------------------------------
	--  Cerco il paziente solo se @PazienteCodiceFiscale <> '0000000000000000' 
	---------------------------------------------------
	IF @PazienteCodiceFiscale <> '0000000000000000' 
	BEGIN
		SELECT TOP 1 @PazienteId = Id FROM Pazienti 
			WHERE Disattivato = 0 AND CodiceFiscale = @PazienteCodiceFiscale
			ORDER BY LivelloAttendibilita DESC, DataModifica DESC
	END 

	--
	-- Restituisco
	--
	SELECT @PazienteId AS PazienteId

END

















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiMsgCercaByCodiceFiscalePaziente] TO [DataAccessDll]
    AS [dbo];

