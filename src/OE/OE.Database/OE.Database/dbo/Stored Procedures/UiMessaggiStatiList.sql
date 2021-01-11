

-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-03-11
-- Modify date: 2013-06-25
--		SANDRO Filtro per DataInserimento e non DataModifica che non ha un indice
-- Description:	Lista messaggi stati
-- =============================================
CREATE PROCEDURE [dbo].[UiMessaggiStatiList]
	  @dataModificaDa datetime2(0) = NULL
	, @dataModificaA datetime2(0) = NULL
	, @Stato tinyint = NULL
	, @codiceAziendaRichiedente varchar(16) = NULL
	, @codiceSistemaRichiedente varchar(16)	= NULL
	, @Anno int	= NULL
	, @Numero int	= NULL
	, @IDRichiestaRichiedente varchar(64) = NULL
	, @IDOrdineTestata uniqueidentifier = NULL
			
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		IF @dataModificaDa IS NULL OR  @dataModificaDa < DATEADD(DAY, -60, GETDATE())
			SET @dataModificaDa = DATEADD(DAY, -1, GETDATE())
			
		IF @dataModificaA IS NULL OR @dataModificaDa > DATEADD(DAY, 1, GETDATE())
			SET @dataModificaA = GETDATE()
		
		SELECT TOP 200
			  M.ID
			, T.ID as IDOrdineTestata
			, (cast(T.Anno as varchar(10)) + '/' + cast(T.Numero as varchar(10))) as Protocollo  		
			, M.DataInserimento
			, M.DataModifica
			, M.IDTicketInserimento
			, M.IDTicketModifica
			, M.IDOrdineErogatoTestata
			, M.IDSistemaRichiedente
			, M.IDRichiestaRichiedente
			, S.CodiceAzienda as CodiceAziendaRichiedente
			, S.Codice as CodiceSistemaRichiedente
			--, M.Messaggio
			, M.Stato
			--, M.Fault
			, CASE M.Stato WHEN 2 THEN
				ISNULL(DettaglioErrore,(dbo.IsNullOrEmpty(dbo.IsNullOrEmpty(
						CAST(M.Fault.query('declare namespace s="http://schemas.datacontract.org/2004/07/OE.DataAccess";/s:StatoFault/s:Errore/text()') AS varchar(max)
						)
					, CAST(M.Fault.query('declare namespace s="http://schemas.progel.it/OE/StatoFault/1";/s:StatoFault/s:Errore/text()') AS varchar(max)
					))
				, CAST(M.Fault.query('declare namespace s="http://schemas.datacontract.org/2004/07/OE.Core";/s:StatoFault/s:Errore/text()') AS varchar(max)
				)))) ELSE DettaglioErrore END AS 'DettaglioErrore'
			  			
		FROM 
			MessaggiStati M
			LEFT JOIN OrdiniErogatiTestate TE WITH(NOLOCK) ON M.IDOrdineErogatoTestata = TE.ID
			LEFT JOIN OrdiniTestate T WITH(NOLOCK) ON TE.IDOrdineTestata = T.ID
			LEFT JOIN Sistemi S WITH(NOLOCK) ON M.IDSistemaRichiedente = S.ID
			
		WHERE
				(M.DataInserimento >= @dataModificaDa AND M.DataInserimento <= @dataModificaA)
			AND ((M.Stato = @Stato) OR (@Stato IS NULL))
			AND ((S.CodiceAzienda = @codiceAziendaRichiedente) OR (@codiceAziendaRichiedente IS NULL))
			AND ((S.Codice = @codiceSistemaRichiedente) OR (@codiceSistemaRichiedente IS NULL))
			AND ((T.Anno = @anno) OR (@anno IS NULL))
			AND ((T.Numero = @numero) OR (@numero IS NULL))
		    AND ((T.IDRichiestaRichiedente = @IDRichiestaRichiedente) OR (@IDRichiestaRichiedente IS NULL))
		    AND (@IDOrdineTestata is null or T.ID = @IDOrdineTestata)
			
		ORDER BY
			DataInserimento DESC

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiMessaggiStatiList] TO [DataAccessUi]
    AS [dbo];

