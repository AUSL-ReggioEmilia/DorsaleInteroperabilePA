
-- ==================================================================
-- Author:		Alessandro Nostini
-- Create date: 2019-01-16
-- Modify date: 2019-01-26 Controllo se permesso il null
--
-- Description:	Controlla se un evento è inviabile a SOLE
--
-- ==================================================================
CREATE FUNCTION [sole].[IsEventoInviabile]
(
 @TipoEventoCodice VARCHAR(16)
,@TipoRicoveroCodice VARCHAR(16)
,@RicoveroStatoCodice TINYINT
,@AllowNull BIT
)
RETURNS BIT
AS
BEGIN
	-- Valido solo  @TipoEventoCodice = A, D, R, X, E (Per la CCH servono anche i T)
	-- Valido solor @TipoRicoveroCodice = 'O', 'D', 'A'
	-- Escludo ricoveri malformati (manca la A p.e.) @RicoveroStatoCodice deve essere diverso da 255
	--
	-- Rimossa esclusione di TipoRicoveroCodice = NULL
	-- Nella procedura di SANDRO i @TipoRicoveroCodice = '' erano esclusi
	-- Nella procedura di ETTORE i @TipoRicoveroCodice = '' erano inclusi
	--   Ora durante la lettura della coda sarà rivalutato
	--
	DECLARE @NullValue VARCHAR(1) = ''
	DECLARE @Ret BIT = 0
	--
	-- Se non è permesso il NULL cambio il chr di controllo
	--
	IF ISNULL(@AllowNull, 0) = 0
		SET @NullValue = '-'

	IF ISNULL(@RicoveroStatoCodice, 0) <> 255
			AND ISNULL(@TipoEventoCodice, @NullValue) IN ('A','D','R','X','E','T', '')
			AND ISNULL(@TipoRicoveroCodice, @NullValue) IN ('O','D','A', '')
	BEGIN
		SET @Ret = 1
	END

	RETURN @Ret
END