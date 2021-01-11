




-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Description:	Restituisce lo stato di una Prenotazione
-- =============================================
CREATE FUNCTION test.dbo_GetPrenotazioneStatoCodice
(
	@AziendaErogante VARCHAR(16)
	,@NumeroNosologico  varchar(64)
)
RETURNS INT
AS
BEGIN
	--
	-- In futuro si dovrà gestire anche lo stato Prenotato=0
	--
	DECLARE @StatoCodice INT
	DECLARE @UltimoEvento_Id AS UNIQUEIDENTIFIER

	SET @StatoCodice = 254 --Prenotazone in stato indefinito

	DECLARE @EsisteIL BIT
	SET @EsisteIL = 0
	--
	-- Determino se il ricovero è valido: se esiste l'accettazione
	--
	IF EXISTS(SELECT * FROM store.EventiBase
			WHERE AziendaErogante = @AziendaErogante
			AND NumeroNosologico = @NumeroNosologico
				AND TipoEventoCodice = 'IL' AND StatoCodice = 0)  --solo attivi
		SET @EsisteIL = 1

	IF @EsisteIL = 1 
	BEGIN 
		--
		-- Cerco ultimo evento 'IL', 'ML', 'DL', 'RL', 'SL'
		-- Uso DataModificaEsterno per ordinare
		--
		SELECT TOP 1
			@UltimoEvento_Id = Id
		FROM
			store.EventiBase
		WHERE 
			AziendaErogante = @AziendaErogante
			AND NumeroNosologico = @NumeroNosologico
			AND StatoCodice = 0 AND TipoEventoCodice IN ('IL', 'ML', 'DL', 'RL', 'SL')
		ORDER BY
			DataModificaEsterno DESC 

		SELECT @StatoCodice =  CASE CONVERT(VARCHAR(1), dbo.GetEventiAttributo(@UltimoEvento_Id, 'CodStatoPrenotazione'))
									WHEN '0' THEN 20 --IN ATTESA
									WHEN '1' THEN 21 --CHIAMATO
									WHEN '2' THEN 22 --RICOVERATO
									WHEN '3' THEN 23 --SOSPESO
									WHEN '4' THEN 24 --ANNULLATO
									ELSE 254		 --Sconosciuto
								END 
	END
	--
	-- Se il valore di r
	--
	RETURN ISNULL(@StatoCodice, 254)
END