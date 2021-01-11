-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-03-03
-- Create date: 2017-09-27 - Aggiunto supporto al PostInCarico oltre che il PostInoltro
-- Description:	Ritorna se l'ordine è cancellabile (i sistemi eroganti supportano la cancellazione)
-- =============================================
CREATE FUNCTION [dbo].[IsOrdineCancellabile](
 @IDOrdineTestata UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN

DECLARE @Ret AS BIT = 0

	DECLARE @stato VARCHAR(4) -- HD, IN, SR, MD, CA
	SELECT @stato = StatoOrderEntry FROM dbo.OrdiniTestate WITH(NOLOCK) WHERE ID = @idOrdineTestata
	IF @stato IN ('IN', 'SR', 'MD')
	BEGIN
		--Calcolo stato da Erogante
		DECLARE @statoErogato VARCHAR(4) -- CA, CM, IP, IC, AA, SE, AR, AE
		SELECT @statoErogato = ISNULL(dbo.GetMinStatoErogatoTestateOrderEntry(@idOrdineTestata), '--')
		
		IF @statoErogato IN ('CA', 'CM', 'IP')
		BEGIN
			-- StatoErogato gia cancellato oppure InProcess o Completato
			-- Non cancellabile
			SET @Ret = 0

		END ELSE BEGIN
			-- StatoErogato IC è PostInCarico
			-- StatoErogato AA, SE, AR, AE è PostInoltro
			-- Cancellabile dipende dal Sistema Erogante

			DECLARE @PostInoltro BIT = 0
			DECLARE @PostInCarico BIT = 0

			IF @statoErogato = 'IC' SET @PostInCarico = 1
			IF @statoErogato IN ('--', 'AA', 'SE', 'AR', 'AE' ) SET @PostInoltro = 1
			--
			-- Conta le righe non cancellabili
			--
			DECLARE @NumRigheNonCancellabili AS INT = 0

			SELECT @NumRigheNonCancellabili = COUNT(*)
			FROM [GetGerarchiaPrestazioniOrdineByIdTestata](@IDOrdineTestata) GP
						INNER JOIN dbo.Prestazioni P ON P .ID = GP.IDFiglio
						INNER JOIN dbo.Sistemi SE ON SE .ID = P.IDSistemaErogante 
			WHERE  (SE.CancellazionePostInoltro = 0 AND @PostInoltro = 1)
				OR  (SE.CancellazionePostInCarico = 0 AND @PostInCarico = 1)

			-- Cancellabile se 0 righe non cancellabili
			--
			IF @NumRigheNonCancellabili = 0	SET @Ret = 1
		END

	END ELSE IF @stato = 'CA' BEGIN
		-- Stato CA, già cancellato
		SET @Ret = 0

	END ELSE BEGIN
		-- Stato HD, posso cancellare
		SET @Ret = 1
	END
					
	RETURN @Ret	
END
