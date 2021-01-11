
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2018-11-08
-- Modify date: 2018-11-12
-- Modify date: 2019-01-21 Se non stato erogato torna stato richiesta
-- Description:	Stato erogato del singolo EROGANTE, se MULTI SETTORE valuta solo la singola testata
--              Copiata da [GetWsDescrizioneStato2]
--				Usata da tutte le SP MsgOrdiniErogatiTestateSelect-xxx
-- =============================================
CREATE FUNCTION [dbo].[GetMsgDescrizioneStatoErogato]
(
 @idOrdineTestata UNIQUEIDENTIFIER
,@idTestataErogata UNIQUEIDENTIFIER
)
RETURNS 
@RetStato TABLE 
(
 Codice VARCHAR(16)
,Descrizione VARCHAR(64)
)
AS
BEGIN
--Inserito = 0
--Inoltrato = 1
--Modificato = 2
--Cancellato = 3
--Accettato = 4
--Rifiutato = 5
--Errato = 6
--Incarico = 7
--Programmato = 8
--Erogato = 9
--Annullato = 10

	DECLARE @stato VARCHAR(4) -- HD, IN, SR, MD, CA
	SELECT @stato = StatoOrderEntry FROM dbo.OrdiniTestate WITH(NOLOCK) WHERE ID = @idOrdineTestata

	--Controllo operazione testata
	IF @stato = 'CA'
		INSERT INTO @RetStato (Codice, Descrizione)	VALUES (@stato, 'Cancellato')

	ELSE IF @stato = 'HD'
		INSERT INTO @RetStato (Codice, Descrizione)	VALUES (@stato, 'Inserito')

	ELSE IF @stato IN ('IN', 'SR', 'MD')
	BEGIN
		-- Controllo stato erogato
		DECLARE @statoErogato VARCHAR(4)
		DECLARE @descrErogato VARCHAR(64)

		--Calcolo stato singola riga Erogante
		SELECT @statoErogato = COALESCE(StatoOrderEntry, StatoRisposta)
			FROM OrdiniErogatiTestate WITH(NOLOCK)
			WHERE Id = @idTestataErogata AND IDOrdineTestata = @IDOrdineTestata 

		-- Calcolo descrizione
		SET @descrErogato = CASE @statoErogato  WHEN 'CA' THEN 'Annullato'
												WHEN 'CM' THEN 'Erogato'
												WHEN 'IP' THEN 'Programmato'
												WHEN 'IC' THEN 'Incarico'

												WHEN 'AA' THEN 'Accettato'
												WHEN 'SE' THEN 'Accettato'
												WHEN 'AR' THEN 'Rifiutato'
												WHEN 'AE' THEN 'Errato'
												ELSE			'Inoltrato' END

		--2019-01-21 Se non stato erogato torna stato richiesta
		SET @statoErogato = ISNULL(@statoErogato, @stato)

		-- Riga di output
		INSERT INTO @RetStato (Codice, Descrizione)	VALUES (@statoErogato, @descrErogato)
	END ELSE BEGIN
		--
		-- Operazione o Stato non definito
		-- Riga di output
		INSERT INTO @RetStato (Codice, Descrizione) VALUES (@stato, 'Inoltrato')
	END
	
	RETURN 
END