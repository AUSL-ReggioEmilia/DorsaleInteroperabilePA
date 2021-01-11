

-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- MODIFICA ETTORE 2017-01-23: L'IdEsterno del ricovero la DAE lo imposta come <AziendaErogante>_<SistemaERogante>_<NumeroNosologico>
--								ma su database viene sempre scritto come <AziendaErogante>_ADT_<NumeroNosologico>
--								Quindi per la ricerca del ricovero devo modificarlo in <AziendaErogante>_ADT_<NumeroNosologico>
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[ExtRicoveriEsiste]
	@IdEsterno as varchar(64)
AS
BEGIN
/*
Controllo se il Ricovero esiste gia e ruitorna la data di modifica esterna
MODIFICA ETTORE 2017-01-23: L'IdEsterno del ricovero la DAE lo imposta come <AziendaErogante>_<SistemaERogante>_<NumeroNosologico>
				ma su database viene sempre scritto come <AziendaErogante>_ADT_<NumeroNosologico>
				Quindi per la ricerca del ricovero devo modificarlo in <AziendaErogante>_ADT_<NumeroNosologico>
*/

DECLARE @IdRicovero as uniqueidentifier
DECLARE @DataModificaEsterno as datetime

	SET NOCOUNT ON

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


	SELECT @IdRicovero = ID, @DataModificaEsterno = DataModificaEsterno 
		FROM store.RicoveriBase WHERE IDEsterno = RTRIM(@IdEsterno)

	IF NOT @IdRicovero IS NULL
		BEGIN	
		SELECT DataModificaEsterno = ISNULL(@DataModificaEsterno, CONVERT(datetime, '1900-01-01', 120))
		END
	ELSE
		BEGIN
		SELECT DataModificaEsterno = NULL
		END

	RETURN @@ERROR
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRicoveriEsiste] TO [ExecuteExt]
    AS [dbo];

