-- =============================================
--
-- Implementazione controlli di cancellazione per catena
-- Regole: 
--	1)se il REFERTO NON È PRESENTE in RefertiBaseRiferimenti lo si può cancellare
--	2)se il REFERTO È PRESENTE in RefertiBaseRiferimenti prendo l'ultimo inserito, 
--    e se il suo IdEsterno è uguale al parametro @IdEsterno della SP lo cancello
--    cioè lo si può cancellare solo se il referto identificato da @IdEsterno è l'ultimo 
--	  che è stato "attaccato" alla catena
--
-- Se il referto non esiste @CancellazioneAbilitata = 0
--
--MODIFICATO SANDRO 2015-11-02: Usa GetRefertiPk()
--								Nella JOIN anche DataPartizione
--								Usa la VIEW [Store]

-- =============================================
CREATE FUNCTION [dbo].[GetRefertiCancellabile2]
(
 @IdEsterno VARCHAR(64)
,@IdRefertiBase UNIQUEIDENTIFIER
,@DataPartizione SMALLDATETIME
)
RETURNS INT
AS
BEGIN
	DECLARE @CancellazioneAbilitata INT = 0
	--
	-- Il referto esiste
	-- 
	DECLARE @IdEsternoRif VARCHAR(64) = NULL

	SELECT TOP 1 @IdEsternoRif = IdEsterno
	FROM [store].RefertiBaseRiferimenti 
		WHERE IdRefertiBase = @IdRefertiBase
			AND DataPartizione = @DataPartizione 
	ORDER BY DataModificaEsterno DESC --Fondamentale

	IF @IdEsternoRif IS NULL
	BEGIN
		--questa è la condizione dei referti standard che non appartengono ad una catena
		SET @CancellazioneAbilitata = 1

	END	ELSE BEGIN
		
		-- c'è nei riferimenti: ricavo i riferimenti e li ordino desc per ricavare l'IdEsterno dell'ultimo riferimento inserito
		IF @IdEsternoRif = @IdEsterno
			SET @CancellazioneAbilitata = 1
	END

	RETURN @CancellazioneAbilitata
END