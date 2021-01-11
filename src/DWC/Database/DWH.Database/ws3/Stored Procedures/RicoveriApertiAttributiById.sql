


CREATE PROCEDURE [ws3].[RicoveriApertiAttributiById]
(
	@IdRicoveri AS IdRicoveri READONLY
)
AS
BEGIN
/*
	CREATA DA ETTORE 2016-10-20
		Restituisce l'elenco degli attributi dei ricoveri nella tabella "IdRicoveri"
		Il controllo di accesso deve essere fatto sul record di testata del ricovero per questo motivo non c'è il parametro @IdToken
		Restituisce gli attributi di ricoveri aperti: non devo quindi calcolare per i PS chiusi il nosologico di destinazione
*/
	SET NOCOUNT ON;
	DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER
	--
	-- La tabella temporanea che contiene gli id di una catena di fusione
	--
	DECLARE @TablePazienti as TABLE (Id UNIQUEIDENTIFIER)
	--
	-- Calcolo il paziente attivo
	--
	SELECT 
		@IdPazienteAttivo  = dbo.GetPazienteAttivoByIdSac(IdPaziente) 
	FROM store.RicoveriBase AS RB
	WHERE 
		EXISTS (SELECT TOP 1 * FROM @IdRicoveri AS TAB WHERE TAB.Id = RB.Id)
	--
	-- Restituisco gli attributi
	--
	SELECT 
		IdRicoveriBase, 
		Nome,
		Valore
	FROM store.RicoveriAttributi AS RA
	WHERE 
		EXISTS (SELECT * FROM @IdRicoveri AS TAB WHERE TAB.Id = RA.IdRicoveriBase)

END