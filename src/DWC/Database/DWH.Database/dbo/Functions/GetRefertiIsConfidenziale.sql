

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetRefertiIsConfidenziale] (
	  @IdRefertiBase AS uniqueidentifier
	, @DataPartizione as smalldatetime
)  
RETURNS BIT AS  
BEGIN 
--
-- Modifica Ettore 2012-11-29: aggiunto test sulle presenza della stringa 'HIV' nelle prestazioni
-- Modifica Ettore 2017-11-06: Modifica eliminazione logiche cablate: tolto uso della function dbo.GetRefertiHasPrestazioniHiv
--
DECLARE @Nome AS VARCHAR(64)
DECLARE @Ret AS SQL_VARIANT

	SET @Nome = 'Confidenziale'
	
	SELECT @Ret = Valore
	FROM store.RefertiAttributi WITH(NOLOCK)
	WHERE IdRefertiBase = @IdRefertiBase AND Nome = @Nome
		AND DataPartizione = @DataPartizione
	
	IF @Ret IS NULL
	BEGIN
		RETURN 0
	END
	
	IF CONVERT( VARCHAR(2), @Ret) = 'NO'
		RETURN 0
		
	IF CONVERT( VARCHAR(2), @Ret) = 'SI'
		RETURN 1

	IF CONVERT( VARCHAR(2), @Ret) = '0'
		RETURN 0

	IF CONVERT( VARCHAR(2), @Ret) = '1'
		RETURN 1
	--
	-- Nessuna trascodifica
	-- Per sicurezza 'riservato'
	--
	RETURN 1
END
