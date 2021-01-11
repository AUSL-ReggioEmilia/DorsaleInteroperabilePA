
-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Description:	Verifica se un evento esiste e restituisce la DataModificaEsterna (NULL se il record non esiste)
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiEsiste]
(
	@IdEsterno as varchar(64)
)
AS
/*
	Controllo se l' evento esiste gia:
	-Se l'evento esiste restituisce la data di DataModificaEsterno
	-Se l'evento non esiste restituisce NULL
*/
DECLARE @IdEvento as uniqueidentifier
DECLARE @DataModificaEsterno as datetime

	SET NOCOUNT ON

	SELECT 
		@IdEvento = Id, 
		@DataModificaEsterno = DataModificaEsterno
	FROM 
		store.EventiBase 
	WHERE 
		IdEsterno = RTRIM(@IdEsterno)

	IF NOT @IdEvento IS NULL
		BEGIN	
		SELECT DataModificaEsterno = ISNULL(@DataModificaEsterno, CONVERT(datetime, '1900-01-01', 120))
		END
	ELSE
		BEGIN
		SELECT DataModificaEsterno = NULL
		END

	RETURN @@ERROR

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiEsiste] TO [ExecuteExt]
    AS [dbo];

