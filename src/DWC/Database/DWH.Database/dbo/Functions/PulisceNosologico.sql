-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2019-06-12
-- Description:	Elimina dal Nosologico gli spazi, i ritorno  a capo e la tabulazione
--				Inoltre se il nosologico è fatto di soli '0' li cancella
-- =============================================
CREATE FUNCTION [dbo].[PulisceNosologico]
(
	@String [varchar](64)
)
RETURNS [varchar](64)
AS
BEGIN
	DECLARE @Ret [varchar](64)

	SET @Ret = @String
	SET @Ret = RTRIM(LTRIM(@Ret))
	SET @Ret = REPLACE(@Ret, CONVERT(VARCHAR(1), 0x0D), '')
	SET @Ret = REPLACE(@Ret, CONVERT(VARCHAR(1), 0x0A), '')
	SET @Ret = REPLACE(@Ret, CONVERT(VARCHAR(1), 0x09), '')
	SET @Ret = NULLIF(@Ret, '')
	--
	-- Solo zeri diventa NULL
	--
	IF (NOT @Ret IS NULL) AND (NULLIF(REPLACE(@Ret, '0', ''), '') IS NULL)
		SET @Ret = NULL

	RETURN @Ret
END