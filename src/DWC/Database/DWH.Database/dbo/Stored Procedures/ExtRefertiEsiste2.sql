/*
Controllo se il referto esiste gia e ruitorna la data di modifica esterna

MODIFICATO SANDRO 2015-11-02: 	Usa GetRefertiPk()
								Nella JOIN anche DataPartizione
								Usa la VIEW [Store]
*/
CREATE PROCEDURE [dbo].[ExtRefertiEsiste2]
	@IdEsterno as varchar(64)
AS
BEGIN

DECLARE @IdReferto uniqueidentifier
DECLARE @DataModificaEsterno datetime
	
	SET NOCOUNT ON

	-- Legge la PK del referto (NOLOCK) e ritorna su [store].RefertiBase

	SELECT @DataModificaEsterno = RefertiBase.DataModificaEsterno 
			, @IdReferto = RefertiBase.ID
	FROM [store].RefertiBase
		INNER JOIN [dbo].[GetRefertiPk](RTRIM(@IdEsterno)) PK
			ON RefertiBase.Id = PK.ID
			AND RefertiBase.DataPartizione = PK.DataPartizione

	IF NOT @IdReferto IS NULL
		SELECT DataModificaEsterno = ISNULL(@DataModificaEsterno, CONVERT(datetime, '1900-01-01', 120))
	ELSE
		SELECT DataModificaEsterno = NULL
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRefertiEsiste2] TO [ExecuteExt]
    AS [dbo];

