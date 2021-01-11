CREATE TABLE [dbo].[OrdiniTestate] (
    [ID]                          UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]             DATETIME2 (3)    NOT NULL,
    [DataModifica]                DATETIME2 (3)    NOT NULL,
    [IDTicketInserimento]         UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]            UNIQUEIDENTIFIER NOT NULL,
    [Anno]                        INT              NOT NULL,
    [Numero]                      INT              NOT NULL,
    [IDUnitaOperativaRichiedente] UNIQUEIDENTIFIER NOT NULL,
    [IDSistemaRichiedente]        UNIQUEIDENTIFIER NOT NULL,
    [NumeroNosologico]            VARCHAR (64)     NULL,
    [IDRichiestaRichiedente]      VARCHAR (64)     NOT NULL,
    [DataRichiesta]               DATETIME2 (0)    NOT NULL,
    [StatoOrderEntry]             VARCHAR (16)     NOT NULL,
    [SottoStatoOrderEntry]        VARCHAR (16)     NULL,
    [StatoRisposta]               VARCHAR (16)     NULL,
    [DataModificaStato]           DATETIME2 (0)    NULL,
    [StatoRichiedente]            XML              NULL,
    [Data]                        DATETIME2 (0)    NULL,
    [Operatore]                   XML              NULL,
    [Priorita]                    XML              NULL,
    [TipoEpisodio]                XML              NULL,
    [AnagraficaCodice]            VARCHAR (64)     NULL,
    [AnagraficaNome]              VARCHAR (16)     NULL,
    [PazienteIdRichiedente]       VARCHAR (64)     NULL,
    [PazienteIdSac]               UNIQUEIDENTIFIER NULL,
    [PazienteRegime]              VARCHAR (16)     NULL,
    [PazienteCognome]             VARCHAR (64)     NULL,
    [PazienteNome]                VARCHAR (64)     NULL,
    [PazienteDataNascita]         DATE             NULL,
    [PazienteSesso]               VARCHAR (1)      NULL,
    [PazienteCodiceFiscale]       VARCHAR (16)     NULL,
    [Paziente]                    XML              NULL,
    [Consensi]                    XML              NULL,
    [Note]                        VARCHAR (MAX)    NULL,
    [DatiRollback]                XML              NULL,
    [Regime]                      XML              NULL,
    [DataPrenotazione]            DATETIME2 (0)    NULL,
    [StatoValidazione]            VARCHAR (16)     NULL,
    [Validazione]                 XML              NULL,
    [StatoTransazione]            VARCHAR (16)     NULL,
    [DataTransazione]             DATETIME2 (0)    NULL,
    CONSTRAINT [PK_OrdiniTestate] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);






GO
CREATE CLUSTERED INDEX [IXC_DataModifica]
    ON [dbo].[OrdiniTestate]([DataModifica] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_NumeroNosologico]
    ON [dbo].[OrdiniTestate]([NumeroNosologico] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_PazienteIdSacDataModifica]
    ON [dbo].[OrdiniTestate]([PazienteIdSac] ASC, [DataModifica] DESC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_DataPrenotazione]
    ON [dbo].[OrdiniTestate]([DataPrenotazione] DESC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_DataRichiesta]
    ON [dbo].[OrdiniTestate]([DataRichiesta] DESC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDSistemaRichiedente]
    ON [dbo].[OrdiniTestate]([IDRichiestaRichiedente] ASC, [IDSistemaRichiedente] ASC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);




GO
CREATE NONCLUSTERED INDEX [IX_UnitaOperativaDataModifica]
    ON [dbo].[OrdiniTestate]([IDUnitaOperativaRichiedente] ASC, [DataModifica] DESC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_DataInserimento]
    ON [dbo].[OrdiniTestate]([DataInserimento] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_UnitaOperativaDataRichiesta]
    ON [dbo].[OrdiniTestate]([IDUnitaOperativaRichiedente] ASC, [DataRichiesta] DESC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Protocollo]
    ON [dbo].[OrdiniTestate]([Anno] ASC, [Numero] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[OrdiniTestate]([IDTicketModifica] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[OrdiniTestate]([IDTicketInserimento] ASC) WITH (FILLFACTOR = 70);

