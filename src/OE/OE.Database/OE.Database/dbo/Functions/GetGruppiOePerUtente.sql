
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-10-29 Legge i dati dal ticket se disponibile
-- Modify date: 2016-09-28 Esendo periodo di validità del token letto al TTL
-- Modify date: 2018-02-06 Sandro - campo CacheGruppiUtente da tabella [dbo].[UtentiGruppiDominio]
--
-- Description:	Seleziona la lista dei Gruppi di OE
-- =============================================
CREATE FUNCTION [dbo].[GetGruppiOePerUtente]
(
 @Utente VARCHAR(64)
)
RETURNS 
    @Result TABLE (
        [ID]          UNIQUEIDENTIFIER NULL,
        [Descrizione] VARCHAR (128)    NULL)
AS
BEGIN

	DECLARE @xmlGruppiUtente xml = NULL
	--
	-- Leggo i dati dalla cache
	--
	SELECT @xmlGruppiUtente = [CacheGruppiUtente]
		FROM [dbo].[UtentiGruppiDominio]
		WHERE [UserName] = @Utente

	IF @xmlGruppiUtente IS NULL	BEGIN

		--Legge dal SAC+OE e ricalcola le membership
		INSERT INTO @Result
		SELECT ID, Descrizione
			FROM [dbo].[RicalcolaGruppiOePerUtente](@Utente)

	END	ELSE BEGIN

		-- Usa i dati letti dalla cache
		INSERT INTO @Result
		SELECT
			Tab.Col.value('@ID','uniqueidentifier') AS ID,
			Tab.Col.value('@Descrizione','varchar(128)') AS Descrizione
		FROM @xmlGruppiUtente.nodes('/GruppiUtente/Gruppo') Tab(Col)
	END

	RETURN 
END
