

-- =============================================
-- Author:      Stefano P.
-- Create date: 2016-10-25
-- Description: Restituisce i consensi del paziente passato
-- =============================================
CREATE PROCEDURE [pazienti_ws].[PazienteConsensiByIdPaziente]
(
	@Identity varchar(64),
	@IdPaziente uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	---------------------------------------------------
	--  Traslo l'IdPaziente nell'attivo/root
	---------------------------------------------------
	SET @IdPaziente = dbo.GetPazienteRootByPazienteId(@IdPaziente)

	SELECT    
		  Id
		, Provenienza
		, IdProvenienza
		, IdPaziente
		, Tipo
		, DataStato
		, Stato
		, OperatoreId
		, OperatoreCognome
		, OperatoreNome
		, OperatoreComputer		
		, Attributi
	FROM
		[pazienti_ws].[Consensi]
	WHERE
		IdPaziente = @IdPaziente
	ORDER BY
	 	IdTipo
	
END