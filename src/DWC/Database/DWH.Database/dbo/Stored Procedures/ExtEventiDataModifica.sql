
-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Description:	Scrive la data di modifica esterna sul record
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiDataModifica]
(	@IdEsterno 		varchar(64),
	@DataModificaEsterno	Datetime
) AS

--Modifico da DataEsterna di un evento

DECLARE @NumRecord int

	SET @NumRecord = 0

	UPDATE  store.EventiBase
	SET	DataModificaEsterno=@DataModificaEsterno
	WHERE IdEsterno=RTRIM(@IdEsterno)

	SET @NumRecord = @@ROWCOUNT

	SELECT INSERTED_COUNT=@NumRecord
	RETURN @@ERROR

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiDataModifica] TO [ExecuteExt]
    AS [dbo];

