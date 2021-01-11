
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-01-28 Nuova versione
-- Description:	Seleziona le righe ordine erogata con dati prestazione
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheErogateSelectByRigaErogante2]
	  @IDOrdineErogatoTestata uniqueidentifier
	, @IDRigaErogante varchar(64)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
		SELECT ore.ID
			, ore.IDOrdineErogatoTestata
			, ore.StatoOrderEntry
			, ore.DataModificaStato
			
			, ore.IDPrestazione
			, p.Codice AS CodicePrestazione
			, p.Descrizione AS DescrizionePrestazione
			, p.Tipo AS TipoPrestazione
			
			, ore.IDRigaRichiedente
			, ore.IDRigaErogante
			, ore.StatoErogante
			, ore.Data
			, ore.Operatore
			, ore.Consensi
			
		FROM OrdiniRigheErogate ore
			INNER JOIN Prestazioni p ON ore.IDPrestazione = p.ID
			
		WHERE ore.IDOrdineErogatoTestata = @IDOrdineErogatoTestata
			AND ore.IDRigaErogante = @IDRigaErogante
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniRigheErogateSelectByRigaErogante2] TO [DataAccessMsg]
    AS [dbo];

