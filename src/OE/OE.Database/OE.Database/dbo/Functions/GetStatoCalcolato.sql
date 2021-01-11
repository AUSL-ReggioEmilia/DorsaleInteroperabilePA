
CREATE FUNCTION [dbo].[GetStatoCalcolato]
(@idOrdineTestata UNIQUEIDENTIFIER)
RETURNS VARCHAR (MAX)
AS
BEGIN

DECLARE @Operazione AS VARCHAR(128)
DECLARE @SottoStatoRic as VARCHAR(128)
DECLARE @SottoStatoErog as VARCHAR(128)
DECLARE @SottoTitolo as VARCHAR(128) = ''

DECLARE @OrdiniErogatiTestate AS TABLE(StatoOrderEntry VARCHAR(16), SottoStatoOrderEntry VARCHAR(16), StatoRisposta VARCHAR(16))
	
	-- Leggo stato e sottostato RICHIEDENTE
	SELECT @Operazione = StatoOrderEntry, @SottoStatoRic = SottoStatoOrderEntry
	FROM dbo.OrdiniTestate WITH(NOLOCK)
	WHERE ID = @idOrdineTestata

	IF @Operazione = 'HD'
	BEGIN
		-- NON è INOLTRATO solo richiedente
		IF @SottoStatoRic = 'INS_00'	SET @SottoTitolo = '<br />In inserimento'
		ELSE							SET @SottoTitolo = ''

		RETURN 'INSERITO' + @SottoTitolo	

	END	ELSE IF @Operazione = 'CA'
	BEGIN
		-- E' stato CANCELLATO

		-- Leggo tutte le testate EROGATO e poi le valuto
		INSERT INTO @OrdiniErogatiTestate(StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta)
		SELECT StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta
		FROM OrdiniErogatiTestate WITH(NOLOCK) WHERE IDOrdineTestata = @IDOrdineTestata 

		-- Controllo ERRORI
		IF EXISTS (SELECT * FROM @OrdiniErogatiTestate	WHERE StatoRisposta ='AE')		SET @SottoTitolo = '<br />Con errori'
		ELSE IF EXISTS (SELECT * FROM @OrdiniErogatiTestate	WHERE StatoRisposta ='AR')	SET @SottoTitolo = '<br />Ma rifiutata'
		ELSE																			SET @SottoTitolo = ''

		RETURN 'CANCELLATO' + @SottoTitolo	
	END	ELSE
	BEGIN
		-- E' stato INOLTRATO

		-- Leggo tutte le testate EROGATO e poi le valuto
		INSERT INTO @OrdiniErogatiTestate(StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta)
		SELECT StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta
		FROM OrdiniErogatiTestate WITH(NOLOCK) WHERE IDOrdineTestata = @IDOrdineTestata 

		-- Controllo se tutti hanno RISPOSTO
		IF EXISTS (SELECT * FROM @OrdiniErogatiTestate WHERE SottoStatoOrderEntry IS NULL)
		BEGIN
			-- E' ancora in INOLTRO (in attesa di RR)
			RETURN 'INOLTRATO <br />In Inoltro'

		END ELSE BEGIN

			-- Legge il MIN degli stati degli EROGANTI che hanno risposto
			DECLARE @statoErogato as VARCHAR(64) = dbo.[GetMinStatoErogatoTestateOrderEntry](@idOrdineTestata)
			IF @statoErogato IS NULL OR @statoErogato = ''
			BEGIN
				-- Controllo se ha già risposto
				SELECT TOP 1 @SottoStatoErog = SottoStatoOrderEntry FROM @OrdiniErogatiTestate
					ORDER BY SottoStatoOrderEntry

				IF EXISTS (SELECT * FROM @OrdiniErogatiTestate	WHERE StatoRisposta ='AE')		SET @SottoTitolo = '<br />Con errori'
				ELSE IF EXISTS (SELECT * FROM @OrdiniErogatiTestate	WHERE StatoRisposta ='AR')	SET @SottoTitolo = '<br />Ma rifiutata'
				ELSE IF @SottoStatoErog IS NULL		SET @SottoTitolo = '<br />In Inoltro'
				ELSE IF @SottoStatoErog = 'ARR_00'	SET @SottoTitolo = '<br />In Inoltro'
				ELSE IF @SottoStatoErog = 'ARR_10'	SET @SottoTitolo = '' 
				ELSE IF @SottoStatoErog = 'UPD_00'	SET @SottoTitolo = '<br />In Inoltro'
				ELSE IF @SottoStatoErog = 'UPD_10'	SET @SottoTitolo = '' 
				ELSE								SET @SottoTitolo = '<br />' + @SottoStatoErog

				-- In attesa della RR
				RETURN 'INOLTRATO' + @SottoTitolo
					
			END ELSE BEGIN

				--Lookup descrizione stato erogato
				DECLARE @Titolo AS VARCHAR(128)
				--SELECT @Titolo = UPPER(Descrizione) FROM OrdiniErogatiStati WITH(NOLOCK) WHERE codice = @statoErogato

				IF @statoErogato = 'CA'			SET @Titolo = 'ANNULLATO' 
				ELSE IF @statoErogato = 'IC'	SET @Titolo = 'IN CARICO' 
				ELSE IF @statoErogato = 'IP'	SET @Titolo = 'PROGRAMMATO' 
				ELSE IF @statoErogato = 'CM'	SET @Titolo = 'EROGATO' 
				ELSE							SET @Titolo = 'INOLTRATO'

				--Ricalcolo SOTTOSTATO da Erogante
				IF @statoErogato = 'SE'	SET @SottoTitolo = '<br />Ricevuto SE' 
				ELSE IF @statoErogato = 'AA'	SET @SottoTitolo = '<br />Accettato' 
				ELSE IF @statoErogato = 'AE'	SET @SottoTitolo = '<br />Errato' 
				ELSE IF @statoErogato = 'AR'	SET @SottoTitolo = '<br />Rifiutato' 
				ELSE							SET @SottoTitolo = ''
			
				RETURN ISNULL(@Titolo, @statoErogato) + @SottoTitolo
			END
		END
	END

	RETURN ''
END
