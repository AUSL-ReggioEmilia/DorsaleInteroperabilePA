
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-03-11
-- Modify date: 2013-06-25
--		SANDRO Filtro per DataInserimento e non DataModifica che non ha un indice
-- Description:	Lista messaggi richieste
-- =============================================
CREATE PROCEDURE [dbo].[UiMessaggiRichiesteList]
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
			, (cast(T.Anno as varchar(10)) + '/' + cast(T.Numero as varchar(10))) as Protocollo  			
			, M.DataInserimento
			, M.DataModifica
			, M.IDTicketInserimento
			, M.IDTicketModifica
			, M.IDOrdineTestata
			, M.IDSistemaRichiedente
			, M.IDRichiestaRichiedente
			, S.CodiceAzienda as CodiceAziendaRichiedente
			, S.Codice as CodiceSistemaRichiedente
			--, M.Messaggio
			, M.Stato
			--, M.Fault
			, CASE M.Stato WHEN 2 THEN
				ISNULL(DettaglioErrore,(dbo.IsNullOrEmpty(dbo.IsNullOrEmpty(
						CAST(M.Fault.query('declare namespace s="http://schemas.datacontract.org/2004/07/OE.DataAccess";/s:RichiestaFault/s:Errore/text()') AS varchar(max)
						)
					, CAST(M.Fault.query('declare namespace s="http://schemas.progel.it/OE/StatoFault/1";/s:RichiestaFault/s:Errore/text()') AS varchar(max)
					))
				, CAST(M.Fault.query('declare namespace s="http://schemas.datacontract.org/2004/07/OE.Core";/s:RichiestaFault/s:Errore/text()') AS varchar(max)
				)))) ELSE DettaglioErrore END AS 'DettaglioErrore'

		FROM 
			MessaggiRichieste M
			LEFT JOIN OrdiniTestate T WITH(NOLOCK) ON M.IDOrdineTestata = T.ID
			LEFT JOIN Sistemi S WITH(NOLOCK) ON M.IDSistemaRichiedente = S.ID
			
		WHERE
				(M.DataInserimento >= @dataModificaDa AND M.DataInserimento <= @dataModificaA)
			AND (@Stato IS NULL OR M.Stato = @Stato)
			AND (@codiceAziendaRichiedente IS NULL OR S.CodiceAzienda = @codiceAziendaRichiedente)
			AND (@codiceSistemaRichiedente IS NULL OR S.Codice = @codiceSistemaRichiedente)
			AND (@anno IS NULL OR T.Anno = @anno)
			AND (@numero IS NULL OR T.Numero = @numero)
			AND (@IDRichiestaRichiedente IS NULL OR T.IDRichiestaRichiedente = @IDRichiestaRichiedente)
			AND (@IDOrdineTestata is null or M.IDOrdineTestata = @IDOrdineTestata)
			
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
    ON OBJECT::[dbo].[UiMessaggiRichiesteList] TO [DataAccessUi]
    AS [dbo];

