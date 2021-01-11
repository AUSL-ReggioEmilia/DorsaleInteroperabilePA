
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2017-11-24 Copiata da [dbo].[CoreDatiAggiuntiviConvert2]
--							Rimosso supporto a XML e anytype
--							per compatibilità usa @ValoreDatoVarchar
--							pianificare rimozione del parametro @ValoreDatoXml
--
-- Description:	Converte un dato aggiuntivo al tipo di dato specificato
-- =============================================
CREATE PROCEDURE [dbo].[CoreDatiAggiuntiviConvert2]
	  @TipoDato varchar(32)
	, @ValoreDato varchar(max)
	, @ValoreDatoSqlVariant sql_variant output
	, @ValoreDatoVarchar varchar(max) output
AS
BEGIN
-- Storia di [dbo].[CoreDatiAggiuntiviConvert]
-- Create date: 2011-02-11 da Pichierri
-- Modifica: 2013-02-07 Sandro: Cambio formattazione date time e datetime
--							salva in formato varchar dentro il variant (per problemi di lettora dati)
--							Aggiunto default se non trova tipo

DECLARE @StrongType as bit = 0

	SET NOCOUNT ON;
	
	SET @ValoreDatoSqlVariant = NULL
	SET @ValoreDatoVarchar = NULL

	------------------------------
	-- CONVERT
	------------------------------
			
	SET @TipoDato = LOWER(REPLACE(@TipoDato,'xs:',''))
	
	--
	-- Stringhe e binery
	--	
	IF (@TipoDato = 'string') OR (@TipoDato = 'base64binary')
	BEGIN
		IF LEN(@ValoreDato) > 8000
			SET @ValoreDatoVarchar = @ValoreDato
		ELSE
			SET @ValoreDatoSqlVariant = CAST(@ValoreDato as varchar(8000))
			
		RETURN
	END
	--
	-- Date e Time
	--
	IF (@TipoDato = 'datetime')
	BEGIN
		IF @StrongType = 1 AND ISDATE(@ValoreDato) = 1
			SET @ValoreDatoSqlVariant = CONVERT(datetime2(0), @ValoreDato)
		
		ELSE IF ISDATE(@ValoreDato) = 1
			SET @ValoreDatoSqlVariant = CONVERT(varchar(32), CONVERT(datetime2(0), @ValoreDato), 126)
			
		ELSE
			SET @ValoreDatoSqlVariant = CONVERT(varchar(32), @ValoreDato)
						
		RETURN
	END
	
	IF (@TipoDato = 'date')
	BEGIN
		IF @StrongType = 1 AND ISDATE(@ValoreDato) = 1
			SET @ValoreDatoSqlVariant = CONVERT(date, @ValoreDato)
			
		ELSE IF ISDATE(@ValoreDato) = 1
			SET @ValoreDatoSqlVariant = CONVERT(varchar(32), CONVERT(date, @ValoreDato), 126)

		ELSE
			SET @ValoreDatoSqlVariant = CONVERT(varchar(32), @ValoreDato)
			
		RETURN
	END
	
	IF (@TipoDato = 'time')
	BEGIN
		IF @StrongType = 1 AND ISDATE(@ValoreDato) = 1
			SET @ValoreDatoSqlVariant = CONVERT(time(0), @ValoreDato)
			
		ELSE IF ISDATE(@ValoreDato) = 1
			SET @ValoreDatoSqlVariant = CONVERT(varchar(12), CONVERT(time(0), @ValoreDato), 126)

		ELSE
			SET @ValoreDatoSqlVariant = CONVERT(varchar(32), @ValoreDato)
		RETURN
	END

	--
	-- Booleani ed interi
	--
	IF @TipoDato = 'boolean'
	BEGIN
		IF @StrongType = 1 AND LOWER(@ValoreDato) IN ('0','1','true','false')
			SET @ValoreDatoSqlVariant = CAST(@ValoreDato as bit)
			
		ELSE IF LOWER(@ValoreDato) IN ('0','1','true','false')
			SET @ValoreDatoSqlVariant = CONVERT(varchar(2), CAST(@ValoreDato as bit))
		ELSE
			SET @ValoreDatoSqlVariant = CONVERT(varchar(32), @ValoreDato)
		
		RETURN
	END
	
	IF @TipoDato = 'byte'
	BEGIN
		IF @StrongType = 1 AND ISNUMERIC(@ValoreDato) = 1 AND CHARINDEX(',', @ValoreDato) = 0
			SET @ValoreDatoSqlVariant = CAST(@ValoreDato as tinyint)
		ELSE
			SET @ValoreDatoSqlVariant = CONVERT(varchar(32), @ValoreDato)
		
		RETURN
	END
				
	IF @TipoDato = 'short'
	BEGIN
		IF @StrongType = 1 AND ISNUMERIC(@ValoreDato) = 1 AND CHARINDEX(',', @ValoreDato) = 0
			SET @ValoreDatoSqlVariant = CAST(@ValoreDato as smallint)
		ELSE
			SET @ValoreDatoSqlVariant = CONVERT(varchar(32), @ValoreDato)
	
		RETURN
	END

	IF (@TipoDato = 'int' OR @TipoDato = 'integer')
	BEGIN
		IF @StrongType = 1 AND ISNUMERIC(@ValoreDato) = 1 AND CHARINDEX(',', @ValoreDato) = 0
			SET @ValoreDatoSqlVariant = CAST(@ValoreDato as int)
		ELSE
			SET @ValoreDatoSqlVariant = CONVERT(varchar(32), @ValoreDato)

		RETURN
	END
		
	IF @TipoDato = 'long'
	BEGIN
		IF @StrongType = 1 AND ISNUMERIC(@ValoreDato) = 1 AND CHARINDEX(',', @ValoreDato) = 0
			SET @ValoreDatoSqlVariant = CAST(@ValoreDato as int)
		ELSE
			SET @ValoreDatoSqlVariant = CONVERT(varchar(32), @ValoreDato)

		RETURN
	END

	--
	-- Numeri float
	--		
	IF @TipoDato = 'decimal'
	BEGIN
		IF @StrongType = 1 AND ISNUMERIC(@ValoreDato) = 1 AND CHARINDEX(',', @ValoreDato) = 0
			SET @ValoreDatoSqlVariant = CAST(@ValoreDato as decimal(18,3))
		ELSE
			SET @ValoreDatoSqlVariant = CONVERT(varchar(32), @ValoreDato)

		RETURN
	END
		
	IF (@TipoDato = 'single' OR @TipoDato = 'real')
	BEGIN
		IF @StrongType = 1 AND ISNUMERIC(@ValoreDato) = 1 AND CHARINDEX(',', @ValoreDato) = 0
			SET @ValoreDatoSqlVariant = CAST(@ValoreDato as real)
		ELSE
			SET @ValoreDatoSqlVariant = CONVERT(varchar(64), @ValoreDato)

		RETURN
	END

	IF (@TipoDato = 'double' OR @TipoDato = 'float')
	BEGIN
		IF @StrongType = 1 AND ISNUMERIC(@ValoreDato) = 1 AND CHARINDEX(',', @ValoreDato) = 0
			SET @ValoreDatoSqlVariant = CAST(@ValoreDato as float)
		ELSE
			SET @ValoreDatoSqlVariant = CONVERT(varchar(64), @ValoreDato)

		RETURN
	END
	
	--
	-- XML
	--
	IF @TipoDato = 'anytype' OR @TipoDato = 'xml'
	BEGIN
		SET @ValoreDatoVarchar = @ValoreDato
		RETURN
	END
	
	-- Se non trovato scrive una stringa
	--
	IF LEN(@ValoreDato) > 8000
		SET @ValoreDatoVarchar = @ValoreDato
	ELSE
		SET @ValoreDatoSqlVariant = CAST(@ValoreDato as varchar(8000))
		
	RETURN
END