CREATE TABLE [dbo].[OrdiniTestate] (
    [ID]                          UNIQUEIDENTIFIER CONSTRAINT [DF_OrdiniTestate_ID] DEFAULT (newid()) NOT NULL,
    [DataInserimento]             DATETIME2 (0)    CONSTRAINT [DF_OrdiniTestate_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]                DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento]         UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]            UNIQUEIDENTIFIER NOT NULL,
    [TS]                          ROWVERSION       NOT NULL,
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
    [AnteprimaPrestazioni]        VARCHAR (MAX)    NULL,
    CONSTRAINT [PK_OrdiniTestate] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_OrdiniTestate_OrdiniSottoStati] FOREIGN KEY ([SottoStatoOrderEntry]) REFERENCES [dbo].[OrdiniSottoStati] ([Codice]),
    CONSTRAINT [FK_OrdiniTestate_OrdiniStati] FOREIGN KEY ([StatoOrderEntry]) REFERENCES [dbo].[OrdiniStati] ([Codice]),
    CONSTRAINT [FK_OrdiniTestate_OrdiniStatiRisposta] FOREIGN KEY ([StatoRisposta]) REFERENCES [dbo].[OrdiniStatiRisposta] ([Codice]),
    CONSTRAINT [FK_OrdiniTestate_Sistemi] FOREIGN KEY ([IDSistemaRichiedente]) REFERENCES [dbo].[Sistemi] ([ID]),
    CONSTRAINT [FK_OrdiniTestate_Tickets_Inserimento] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID]),
    CONSTRAINT [FK_OrdiniTestate_Tickets_Modifica] FOREIGN KEY ([IDTicketModifica]) REFERENCES [dbo].[Tickets] ([ID]),
    CONSTRAINT [FK_OrdiniTestate_UnitaOperative] FOREIGN KEY ([IDUnitaOperativaRichiedente]) REFERENCES [dbo].[UnitaOperative] ([ID])
);










GO



GO



GO



GO



GO
CREATE NONCLUSTERED INDEX [IX_DataModifica]
    ON [dbo].[OrdiniTestate]([DataModifica] ASC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);


GO



GO



GO
CREATE NONCLUSTERED INDEX [IX_PazienteIdSacDataModifica]
    ON [dbo].[OrdiniTestate]([PazienteIdSac] ASC, [DataModifica] DESC)
    INCLUDE([ID]) WITH (FILLFACTOR = 90);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID ordine del Sistema Richiedente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrdiniTestate', @level2type = N'COLUMN', @level2name = N'IDRichiestaRichiedente';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Data ordine del Sistema Richiedente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrdiniTestate', @level2type = N'COLUMN', @level2name = N'DataRichiesta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrdiniTestate', @level2type = N'COLUMN', @level2name = N'StatoOrderEntry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Data di versione della richiesta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrdiniTestate', @level2type = N'COLUMN', @level2name = N'Data';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'(C)ommit; (R)ollback;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrdiniTestate', @level2type = N'COLUMN', @level2name = N'StatoTransazione';


GO
CREATE NONCLUSTERED INDEX [IX_UnitaOperativaDataRichiesta]
    ON [dbo].[OrdiniTestate]([IDUnitaOperativaRichiedente] ASC, [DataRichiesta] DESC)
    INCLUDE([ID]) WITH (FILLFACTOR = 75);


GO
CREATE NONCLUSTERED INDEX [IX_UnitaOperativaDataModifica]
    ON [dbo].[OrdiniTestate]([IDUnitaOperativaRichiedente] ASC, [DataModifica] DESC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[OrdiniTestate]([IDTicketModifica] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[OrdiniTestate]([IDTicketInserimento] ASC);


GO
CREATE UNIQUE CLUSTERED INDEX [IXC_Protocollo]
    ON [dbo].[OrdiniTestate]([Anno] ASC, [Numero] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_NumeroNosologico]
    ON [dbo].[OrdiniTestate]([NumeroNosologico] ASC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDSistemaRichiedente]
    ON [dbo].[OrdiniTestate]([IDSistemaRichiedente] ASC, [IDRichiestaRichiedente] ASC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);




GO
CREATE NONCLUSTERED INDEX [IX_DataRichiesta]
    ON [dbo].[OrdiniTestate]([DataRichiesta] DESC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_DataPrenotazione]
    ON [dbo].[OrdiniTestate]([DataPrenotazione] DESC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDRichiestaRichiedente]
    ON [dbo].[OrdiniTestate]([IDRichiestaRichiedente] ASC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);

