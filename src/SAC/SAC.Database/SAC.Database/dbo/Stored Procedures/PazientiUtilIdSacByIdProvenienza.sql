
/*
	Ritorna lo stesso schema della PazientiOutputByIdProvenienza2 con la differenza
	che gli attributi RegioneResCodice e RegioneAssCodice sono un varchar(2)
*/
CREATE PROCEDURE [dbo].[PazientiUtilIdSacByIdProvenienza]
	@Provenienza varchar(16),
	@IdProvenienza varchar(64)

AS
BEGIN

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
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiUtilIdSacByIdProvenienza', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiUtilIdSacByIdProvenienza!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT TOP 1
		  Id
		--, Provenienza
		--, IdProvenienza
		--, DataInserimento
		--, DataModifica

		--, Tessera
		, Cognome
		, Nome
		, DataNascita
		, Sesso		
		, CodiceFiscale
		, StatusCodice
		, 'StatusNome' = 
			CASE			
				WHEN StatusCodice = 0 THEN 'Attivo'
				WHEN StatusCodice = 1 THEN 'Cancellato'
				WHEN StatusCodice = 2 THEN 'Fuso'
			END
	FROM 
		PazientiDettaglioResult
	WHERE
		(	Provenienza = @Provenienza
		AND IdProvenienza = @IdProvenienza)
	OR
		( PazientiDettaglioResult.Id IN (
							SELECT PazientiSinonimi.IdPaziente
							FROM         
								PazientiSinonimi
							WHERE
									PazientiSinonimi.Provenienza = @Provenienza
								AND PazientiSinonimi.IdProvenienza = @IdProvenienza
										)
		)
	ORDER BY
		StatusCodice

END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUtilIdSacByIdProvenienza] TO [DataAccessSql]
    AS [dbo];

