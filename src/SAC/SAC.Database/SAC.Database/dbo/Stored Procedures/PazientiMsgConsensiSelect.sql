

-- =============================================
-- Author:		ETTORE
-- Create date: 2018-07-27
-- Description:	Restituisce la lista dei consensi del paziente (usata per costruire la risposta)
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgConsensiSelect]
	@IdPaziente AS uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
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
		ConsensiSpResult
	WHERE
		IdPaziente = @IdPaziente
	ORDER BY
	 	IdTipo
END;
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgConsensiSelect] TO [DataAccessDll]
    AS [dbo];

