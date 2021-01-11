
CREATE PROCEDURE [dbo].[SrvcStampeSottoscrizioniCodaDaProcessareAggiungi]
(
	@IdStampeSottoscrizioni UNIQUEIDENTIFIER,
	@IdReferto UNIQUEIDENTIFIER,
	@DataModificaReferto as datetime
)
AS
BEGIN
/*
Stato:
		DaSottomettere = 1
        Sottomessa = 2
        Terminata = 3
*/
	SET NOCOUNT ON;
	--
	-- Se esiste già un record nella coda per lo stesso referto aggiorno
	-- altrimenti lo inserisco
	--
	IF EXISTS(SELECT * FROM StampeSottoscrizioniCoda
				WHERE (IdStampeSottoscrizioni = @IdStampeSottoscrizioni)
					  AND (IdReferto = @IdReferto)
					  AND (DataSottomissione IS NULL) --da sottomettere
					  AND (ISNULL(Errore,'') ='') --non in errore
				)
	BEGIN
		--Aggiorno il record		
		UPDATE StampeSottoscrizioniCoda
			SET CounterModificheReferto = CounterModificheReferto + 1,
				DataModificaReferto = @DataModificaReferto,
				DataModifica = GETDATE(),
				Errore = NULL --cosi sono sicuro di riprocessare il record
		WHERE
			(IdStampeSottoscrizioni = @IdStampeSottoscrizioni)
			AND (IdReferto = @IdReferto)
			AND (DataSottomissione IS NULL) --da sottomettere
			AND (ISNULL(Errore,'') ='') --non in errore

	END
	ELSE
	BEGIN
		--
		-- Modifica Ettore 2013-04-22: per inserire mi assicuro che la sottoscrizione esista 
		-- (cosi si può cancellare una sottoscrizione e i suoi figli anche se il servizio la sta elaborando 
		-- senza creare errori di costrain)
		--
		INSERT INTO StampeSottoscrizioniCoda
		   ([Id]
		   ,[IdStampeSottoscrizioni]
		   ,[IdReferto]
		   ,[DataModificaReferto]
		   ,[Errore])
		SELECT NewId()
		   ,Id --@IdStampeSottoscrizioni
		   ,@IdReferto
		   ,@DataModificaReferto
		   ,NULL
		FROM 
			StampeSottoscrizioni 
		WHERE 
			Id = @IdStampeSottoscrizioni
	
	END

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeSottoscrizioniCodaDaProcessareAggiungi] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeSottoscrizioniCodaDaProcessareAggiungi] TO [ExecuteService]
    AS [dbo];

