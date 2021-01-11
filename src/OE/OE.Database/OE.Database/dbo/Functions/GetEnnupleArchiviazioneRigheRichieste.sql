

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2020-04-20
--
-- Description:	Calcola il valore dei giorni di archivazione valutando le righe (sistema erogante)
--				Il calcolo tiene conto che le ennuple posso coincidere parzialmente
--					e tramite un peso si raggruppano e ritornano in ordine
--				Deve tornare solo 1 record
--
-- =============================================
CREATE FUNCTION [dbo].[GetEnnupleArchiviazioneRigheRichieste]
(
 @idSistemaRichiedente UNIQUEIDENTIFIER
,@idUnitaOperativa UNIQUEIDENTIFIER
,@idOrdineTestata UNIQUEIDENTIFIER
)
RETURNS 
    @Result TABLE (
        [IdOrdineTestata] UNIQUEIDENTIFIER NOT NULL,
        [GiorniOrdiniCompletati] INT NOT NULL,
        [GiorniOrdiniNoRisposta] INT NOT NULL,
        [GiorniOrdiniPrenotazioniPassate] INT NOT NULL,
        [GiorniOrdiniAltro] INT NOT NULL,
        [GiorniVersioniCompletati] INT NOT NULL,
        [GiorniVersioniPrenotazioniPassate] INT NOT NULL,
        [Peso] INT NOT NULL)
AS
BEGIN
	--
	-- Primo step match completo
	--
	DECLARE @Righe AS TABLE (IDOrdineTestata UNIQUEIDENTIFIER, IDSistemaErogante UNIQUEIDENTIFIER)
	
	INSERT INTO @Righe
	SELECT IDOrdineTestata, IDSistemaErogante
	FROM [dbo].[OrdiniRigheRichieste] r WITH(NOLOCK)
	WHERE r.IDOrdineTestata = @idOrdineTestata

	IF EXISTS (SELECT * FROM @Righe)
	BEGIN
		--
		-- Righe trovate
		--
		INSERT INTO @Result
		SELECT @idOrdineTestata AS [IdOrdineTestata]
			,MAX([GiorniOrdiniCompletati]) AS [GiorniOrdiniCompletati]
			,MAX([GiorniOrdiniNoRisposta]) AS [GiorniOrdiniNoRisposta]
			,MAX([GiorniOrdiniPrenotazioniPassate]) AS [GiorniOrdiniPrenotazioniPassate]
			,MAX([GiorniOrdiniAltro]) AS [GiorniOrdiniAltro]
			,MAX([GiorniVersioniCompletati]) AS [GiorniVersioniCompletati]
			,MAX([GiorniVersioniPrenotazioniPassate]) AS [GiorniVersioniPrenotazioniPassate]
			,MAX([Peso]) AS [Peso]
		FROM @Righe r
			CROSS APPLY [dbo].[GetEnnupleArchiviazione](@IdSistemaRichiedente, @IDUnitaOperativa, r.[IDSistemaErogante]) e
	END

	IF NOT EXISTS (SELECT * FROM @Result)
	BEGIN
		--
		-- Ultimo step nessuna riga, uso dei default
		--
		INSERT INTO @Result
		SELECT @idOrdineTestata AS [IdOrdineTestata]
			,[GiorniOrdiniCompletati]
			,[GiorniOrdiniNoRisposta]
			,[GiorniOrdiniPrenotazioniPassate]
			,[GiorniOrdiniAltro]
			,[GiorniVersioniCompletati]
			,[GiorniVersioniPrenotazioniPassate]
			,[Peso]
		FROM [dbo].[GetEnnupleArchiviazione](@IdSistemaRichiedente, @IDUnitaOperativa, NULL)
	END

	RETURN
END