-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-08-04
-- Modify date: 2015-09-04 Stefano : Aggiunto stato in inoltro e parametro @SottoStatoOrderEntry
-- Modify date: 2015-10-20 Sandro : Per valutare se in inoltro usa dbo.OrdiniErogatiTestate 
-- Modify date: 2015-10-21 Stefano : eliminato parametro @NullSkip
-- Description: Recupera lo stato dell'ordine
-- =============================================
CREATE FUNCTION [dbo].[GetStatoSenzaSottostato2]
(
	@idOrdineTestata UNIQUEIDENTIFIER,
	@OrdiniTestateStatoOrderEntry VARCHAR(16)
)
RETURNS VARCHAR (64)

AS
BEGIN	

	-- Cancellato non controlla le risposte
	IF @OrdiniTestateStatoOrderEntry = 'CA'
	BEGIN
		RETURN 'Cancellato'
	END

	--Operazione di INOLTRO
	IF (@OrdiniTestateStatoOrderEntry = 'SR' OR @OrdiniTestateStatoOrderEntry = 'MD' )
	BEGIN
		-- Controlla se hanno risposto
		IF EXISTS (SELECT * FROM dbo.OrdiniErogatiTestate WITH(NOLOCK)
						WHERE IDOrdineTestata = @idOrdineTestata AND SottoStatoOrderEntry IS NULL)
		BEGIN
			RETURN 'In Inoltro'
		END ELSE BEGIN

			-- L'erogante ha risposto
			IF EXISTS (SELECT * FROM dbo.OrdiniErogatiTestate WITH(NOLOCK)
					WHERE IDOrdineTestata = @idOrdineTestata and StatoRisposta IN ('AE', 'AR'))
			BEGIN 
				RETURN 'Errato'
			END ELSE BEGIN
				-- Nessun errore

				DECLARE @statoErogato VARCHAR(16) =  dbo.GetMinStatoErogatoTestateOrderEntry(@idOrdineTestata)
				IF @statoErogato IS NULL
				BEGIN
					RETURN 'Inoltrato'
				END

				--Lookup descrizione stato erogato
				DECLARE @Titolo AS VARCHAR(128) = 'Inoltrato' 
				SELECT @Titolo = Descrizione FROM OrdiniErogatiStati WITH(NOLOCK) WHERE Codice = @statoErogato
		
				RETURN @Titolo
			END
		END

	END ELSE IF @OrdiniTestateStatoOrderEntry = 'HD'
	BEGIN
		-- Solo inserita
		RETURN 'Inserito'
	END

	RETURN ''
END
