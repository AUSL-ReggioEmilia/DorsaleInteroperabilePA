
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-05-12
-- Modify date: 2013-03-19
-- Description:	Rollback della testata d'ordine
-- =============================================
CREATE PROCEDURE [dbo].[MsgRollbackOrdiniTestateUpdate]
	  @ID uniqueidentifier
	, @DataInserimento datetime
	, @DataModifica datetime
	, @IDTicketInserimento uniqueidentifier
	, @IDTicketModifica uniqueidentifier
	, @Anno int
	, @Numero int
	, @IDUnitaOperativaRichiedente uniqueidentifier	
	, @IDSistemaRichiedente uniqueidentifier
	, @NumeroNosologico varchar(64)
	, @IDRichiestaRichiedente varchar(64)
	, @DataRichiesta datetime
	, @StatoOrderEntry varchar(16)
	, @SottoStatoOrderEntry varchar(16)
	, @StatoRisposta varchar(16)
	, @DataModificaStato datetime
	, @StatoRichiedente xml
	, @Data datetime
	, @Operatore xml
	, @Priorita xml
	, @TipoEpisodio xml
	, @AnagraficaCodice varchar(64)
	, @AnagraficaNome  varchar(16)
	, @PazienteIdRichiedente varchar(64)
	, @PazienteIdSac uniqueidentifier
	, @PazienteRegime varchar(16)
	, @PazienteCognome varchar(64)
	, @PazienteNome varchar(64)
	, @PazienteDataNascita datetime
	, @PazienteSesso varchar(1)
	, @PazienteCodiceFiscale varchar(16)
	, @Paziente xml
	, @Consensi xml
	, @Note varchar(max)
-- Modificato 2013-03-19
	, @Regime xml = NULL
	, @DataPrenotazione datetime2(0) = NULL
	, @StatoValidazione  varchar(16) = NULL
	, @Validazione xml = NULL
	, @StatoTransazione  varchar(16) = NULL
	, @DataTransazione datetime2(0) = NULL
AS
BEGIN
--
-- Modificata: SANDRO 2013-03-19 Nuovoi parametri 
--
	SET NOCOUNT ON

	BEGIN TRY
	
		------------------------------
		-- UPDATE
		------------------------------		
		UPDATE OrdiniTestate
			SET			
				  DataInserimento = @DataInserimento
				, DataModifica = @DataModifica
				, IDTicketInserimento = @IDTicketInserimento
				, IDTicketModifica = @IDTicketModifica
				, Anno = @Anno
				, Numero = @Numero
				, IDUnitaOperativaRichiedente = @IDUnitaOperativaRichiedente
				, IDSistemaRichiedente = @IDSistemaRichiedente
				, NumeroNosologico = @NumeroNosologico
				, IDRichiestaRichiedente = @IDRichiestaRichiedente
				, DataRichiesta = @DataRichiesta
				, StatoOrderEntry = @StatoOrderEntry
				, SottoStatoOrderEntry = @SottoStatoOrderEntry
				, StatoRisposta = @StatoRisposta
				, DataModificaStato = @DataModificaStato
				, StatoRichiedente = @StatoRichiedente
				, Data = @Data
				, Operatore = @Operatore
				, Priorita = @Priorita
				, TipoEpisodio = @TipoEpisodio
				, AnagraficaCodice = @AnagraficaCodice
				, AnagraficaNome = @AnagraficaNome
				, PazienteIdRichiedente = @PazienteIdRichiedente
				, PazienteIdSac = @PazienteIdSac
				, PazienteRegime = @PazienteRegime
				, PazienteCognome = @PazienteCognome
				, PazienteNome = @PazienteNome
				, PazienteDataNascita = @PazienteDataNascita
				, PazienteSesso = @PazienteSesso
				, PazienteCodiceFiscale = @PazienteCodiceFiscale
				, Paziente = @Paziente
				, Consensi = @Consensi
				, Note = @Note
				, DatiRollback = NULL
				-- Modificato 2013-03-19
				, Regime = @Regime
				, DataPrenotazione = @DataPrenotazione
				, StatoValidazione = @StatoValidazione
				, Validazione = @Validazione
				, StatoTransazione = @StatoTransazione
				, DataTransazione = @DataTransazione
			WHERE
				ID = @ID
								
		SELECT @@ROWCOUNT AS [ROWCOUNT]
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
		
		SELECT @@ROWCOUNT AS [ROWCOUNT]
	END CATCH
		
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgRollbackOrdiniTestateUpdate] TO [DataAccessMsg]
    AS [dbo];

