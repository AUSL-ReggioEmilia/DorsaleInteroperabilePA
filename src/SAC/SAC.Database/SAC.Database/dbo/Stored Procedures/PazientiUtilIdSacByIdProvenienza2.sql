-- =============================================
-- Author:		Ettore
-- Create date: 2012-10-29
-- Description:	SP creata per ELCO. Restituisce l'id del paziente per provenienza
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUtilIdSacByIdProvenienza2]
	@Provenienza varchar(16),
	@IdProvenienza varchar(64)

AS
BEGIN
--
--	Restituisce il solo campo Id della tabella Pazienti
--	Utilizzata da ELCO
--

	DECLARE @Identity AS varchar(64)

	SET NOCOUNT ON;

	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Il parametro Provenienza non può essere NULL!', 16, 1)
		RETURN
	END

	IF @IdProvenienza IS NULL
	BEGIN
		RAISERROR('Il parametro IdProvenienza non può essere NULL!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	SET @Identity = USER_NAME()

	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiUtilIdSacByIdProvenienza2', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiUtilIdSacByIdProvenienza2!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Ritorna i dati
	--  Uso direttamente la tabella Pazienti
	---------------------------------------------------

	SELECT TOP 1
		  Id
	FROM 
		Pazienti
	WHERE
		(	Provenienza = @Provenienza
		AND IdProvenienza = @IdProvenienza)
	OR
		( Pazienti.Id IN (
							SELECT PazientiSinonimi.IdPaziente
							FROM         
								PazientiSinonimi
							WHERE
									PazientiSinonimi.Provenienza = @Provenienza
								AND PazientiSinonimi.IdProvenienza = @IdProvenienza
										)
		)
	ORDER BY
		Disattivato --0=Attivo,1=Cancellato,2=Fuso

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUtilIdSacByIdProvenienza2] TO [DataAccessSql]
    AS [dbo];

