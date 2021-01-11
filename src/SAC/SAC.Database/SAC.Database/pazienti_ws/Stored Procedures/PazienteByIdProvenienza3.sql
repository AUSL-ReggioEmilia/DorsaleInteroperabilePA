
-- =============================================
-- Author:		ETTORE
-- Create date: 2020-05-07 (derivata da versione precedente creata il 2016-12-27)
--				Creatya per utilizzare versione 3 delle SP
-- Description:	Ottiene un record completo di PazientiDettaglio
-- =============================================
CREATE PROCEDURE [pazienti_ws].[PazienteByIdProvenienza3]
(
	@Identity varchar(64),
	@Provenienza varchar(16),
	@IdProvenienza varchar(64)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	-- Controllo accesso
	--
	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, 'PazienteByIdProvenienza', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazienteByIdProvenienza!', 16, 1)
		RETURN
	END
	
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	SELECT @IdPaziente = pazienti_ws.GetPazienteByProvenienzaIdProvenienza (@Provenienza, @IdProvenienza)

	EXECUTE [pazienti_ws].[PazienteById3] @Identity, @IdPaziente

END