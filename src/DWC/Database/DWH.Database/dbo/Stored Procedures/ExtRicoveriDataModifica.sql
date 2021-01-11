
-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- MODIFICA ETTORE 2017-01-23: L'IdEsterno del ricovero deve essere sempre cercato come <AziendaErogante>_ADT_<NumeroNosologico>
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[ExtRicoveriDataModifica]
(	
	@IdEsterno 				VARCHAR(64),
	@DataModificaEsterno	DATETIME
) AS
	--------------------------------------------------------------------------------------------
	-- Modifica temporanea in attesa di cambiare la DAE
	--------------------------------------------------------------------------------------------
	DECLARE @Pos1 INT 
	DECLARE @Pos2 INT 
	DECLARE @Azienda VARCHAR(64)
	DECLARE @Nosologico  VARCHAR(64)

	SET @Pos1 = CHARINDEX('_',@IdEsterno , 1 )   
	SET @Pos2 = CHARINDEX('_',@IdEsterno , @Pos1 + 1)   
	SET @Azienda= LEFT(@IdEsterno, @Pos1 -1)
	SET @Nosologico = RIGHT(@IdEsterno, LEN(@IdEsterno) - @Pos2)
	--MODIFICA ETTORE 2017-01-23: L'IdEsterno del ricovero deve essere sempre cercato come <AziendaErogante>_ADT_<NumeroNosologico>
	SET @IdEsterno = @Azienda + '_ADT_' + @Nosologico
	--------------------------------------------------------------------------------------------
--
-- Modifico da DataEsterna di un Ricovero
--

	DECLARE @NumRecord int
	SET @NumRecord = 0

	UPDATE store.RicoveriBase
		SET	DataModificaEsterno=@DataModificaEsterno
	WHERE IdEsterno=RTRIM(@IdEsterno)

	SET @NumRecord = @@ROWCOUNT

	SELECT INSERTED_COUNT=@NumRecord
	RETURN @@ERROR




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRicoveriDataModifica] TO [ExecuteExt]
    AS [dbo];

