CREATE FUNCTION [dbo].[GetPazienteByProvenienzaIdProvenienza]
(
	@Provenienza varchar(16),
	@IdProvenienza varchar(64)
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
/*
	CREATA DA ETTORE 2014-07-07: Questa funzione è stata introdotta per disaccoppiare la SP di output "PazientiOutputCercaByProvenienzaIdProvenienzaOrAggiunge"
				dalla SP WS "PazientiWsDettaglioByIdProvenienza" la quale conteneva la logica implementata in questa funzione 

*/
	DECLARE @IdPaziente UNIQUEIDENTIFIER

	IF @Provenienza <> 'SAC'
	BEGIN
		SELECT TOP 1 
			@IdPaziente = Id
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
	ELSE
	BEGIN
		DECLARE @Disattivato AS TINYINT
		--
		-- Se @Provenienza = SAC allora @IdProvenienza è il guid del record paziente
		-- Verifico che @IdProvenienza sia un GUID
		--
		IF dbo.IsGUID(@IdProvenienza) = 1
		BEGIN 
			SELECT 
				@IdPaziente = Id
				, @Disattivato = Disattivato
			FROM Pazienti
			WHERE 
				Id = @IdProvenienza
		END
		--
		-- Se fuso cerco l'Id del padre
		--
		IF @Disattivato = 2 
		BEGIN
			--
			-- Cerco il padre della fusione
			--
			SELECT TOP 1 @IdPaziente = IdPaziente 
			FROM PazientiFusioni 
			WHERE IdPazienteFuso = @IdPaziente  AND Abilitato = 1
		END
	END	
	--
	-- Return the result of the function
	--
	RETURN @Idpaziente

END
