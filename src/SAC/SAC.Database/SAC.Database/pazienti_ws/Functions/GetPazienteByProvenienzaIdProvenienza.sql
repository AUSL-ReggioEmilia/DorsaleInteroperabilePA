
-- =============================================
-- Author:		Stefano P
-- Create date: 2017-01-13
-- Description:	Ottiene l'ID del paziente con @Provenienza,@IdProvenienza qualunque sia il suo stato
--				IN CASO DI FUSIONE NON TRASLA IL PAZIENTE NEL PAZIENTE ROOT
--				se c'è un attivo o cancellato, sono unici, 
--				se c'è più di un record fuso, ordino per DataDisattivazione più recente
-- =============================================
CREATE FUNCTION [pazienti_ws].[GetPazienteByProvenienzaIdProvenienza]
(
	@Provenienza varchar(16),
	@IdProvenienza varchar(64)
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @IdPaziente UNIQUEIDENTIFIER

	IF @Provenienza <> 'SAC'
	BEGIN
		SELECT TOP 1 
			@IdPaziente = Id
		FROM 
			dbo.Pazienti
		WHERE
			Provenienza = @Provenienza
			AND IdProvenienza = @IdProvenienza
		ORDER BY
		-- se c'è un attivo o cancellato, sono unici, 
		-- se c'è più di un record fuso, ordino per DataDisattivazione più recente
			Disattivato, DataDisattivazione DESC 
	END
	ELSE BEGIN
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
			FROM 
				dbo.Pazienti
			WHERE 
				Id = @IdProvenienza
		END	
	END	
	--
	-- Return the result of the function
	--
	RETURN @Idpaziente

END