
/*
MODIFICATO SANDRO 2015-11-02: Rimosso GetRefertiIsStorico()
								Usa GetRefertiPk()
								Nella JOIN anche DataPartizione
								Usa la VIEW [Store]
Modify date: 2018-06-08 - ETTORE - Uso della funzione dbo.GetRefertiPK() al posto della dbo.GetRefertiId()
*/
CREATE PROCEDURE [dbo].[ExtRefertiDataModifica]
(	@IdEsterno 		varchar(64),
	@DataModificaEsterno	Datetime
) AS
BEGIN
--
-- Modifico la DataEsterna di un referto
--
DECLARE @IdReferto UNIQUEIDENTIFIER
DECLARE @NumRecord int
DECLARE @Err int

	SET @NumRecord = 0

	--Modifica Ettore 13/04/2012 per catena referti: uso la funzione per trovare il record
	--Modify date: 2018-06-08 - ETTORE
	-- Legge la PK del referto (non ho bisogno della @DataPartizione)
	SELECT @IdReferto = ID --, @DataPartizione = DataPartizione
		FROM [dbo].[GetRefertiPk](RTRIM(@IdEsterno))

	
	UPDATE [store].RefertiBase
	SET	DataModificaEsterno=@DataModificaEsterno
	WHERE Id = @IdReferto --cerco per Id guid del referto

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR

	SELECT INSERTED_COUNT = @NumRecord
	RETURN @Err
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRefertiDataModifica] TO [ExecuteExt]
    AS [dbo];

