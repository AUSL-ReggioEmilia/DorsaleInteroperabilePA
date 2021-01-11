

CREATE PROCEDURE [frontend].[CancellazionePazienteAggiungi]
@IdPazientiBase	uniqueidentifier
--@IdRepartiEroganti	uniqueidentifier = NULL
 AS
/*

	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.CancellazionePazienteAggiungi
		Aggiunge un paziente nella tabella dei pazienti cancellati
		La precedente versione permettava la cancellazione anche per @IdRepartiEroganti
		Restituisco il paziente cancellato cosi che il designere non crei un QueryTableAdapter
		ma un table adapter standard
*/

SET NOCOUNT ON

IF NOT EXISTS(SELECT * FROM PazientiCancellati WHERE IdPazientiBase = @IdPazientiBase)
BEGIN
	INSERT INTO PazientiCancellati(Id, IdPazientiBase, DataCancellazione) 
	VALUES
		(NEWID(), @IdPazientiBase, GETDATE())
--
-- Restituisco il paziente cancellato
--
SELECT IdPazientiBase FROM PazientiCancellati WHERE IdPazientiBase = @IdPazientiBase		
END
		

