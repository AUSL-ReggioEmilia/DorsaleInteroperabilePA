CREATE TABLE [dbo].[OrdiniErogatiTestate] (
    [ID]                       UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]          DATETIME2 (0)    NOT NULL,
    [DataModifica]             DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento]      UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]         UNIQUEIDENTIFIER NOT NULL,
    [TS]                       ROWVERSION       NOT NULL,
    [IDOrdineTestata]          UNIQUEIDENTIFIER NULL,
    [IDSistemaRichiedente]     UNIQUEIDENTIFIER NULL,
    [IDRichiestaRichiedente]   VARCHAR (64)     NULL,
    [IDSistemaErogante]        UNIQUEIDENTIFIER NOT NULL,
    [IDRichiestaErogante]      VARCHAR (64)     NULL,
    [StatoOrderEntry]          VARCHAR (16)     NULL,
    [SottoStatoOrderEntry]     VARCHAR (16)     NULL,
    [StatoRisposta]            VARCHAR (16)     NULL,
    [StatoOrderEntryAggregato] VARCHAR (MAX)    NULL,
    [DataModificaStato]        DATETIME2 (0)    NULL,
    [StatoErogante]            XML              NULL,
    [Data]                     DATETIME2 (0)    NULL,
    [Operatore]                XML              NULL,
    [AnagraficaCodice]         VARCHAR (64)     NULL,
    [AnagraficaNome]           VARCHAR (16)     NULL,
    [PazienteIdRichiedente]    VARCHAR (64)     NULL,
    [PazienteIdSac]            UNIQUEIDENTIFIER NULL,
    [PazienteCognome]          VARCHAR (64)     NULL,
    [PazienteNome]             VARCHAR (64)     NULL,
    [PazienteDataNascita]      DATETIME2 (0)    NULL,
    [PazienteSesso]            VARCHAR (1)      NULL,
    [PazienteCodiceFiscale]    VARCHAR (16)     NULL,
    [Paziente]                 XML              NULL,
    [Consensi]                 XML              NULL,
    [Note]                     VARCHAR (MAX)    NULL,
    [DataPrenotazione]         DATETIME2 (0)    NULL,
    [IDSplit]                  TINYINT          NULL,
    CONSTRAINT [PK_OrdiniErogatiTestate] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_OrdiniErogatiTestate_OrdiniErogatiSottoStati] FOREIGN KEY ([SottoStatoOrderEntry]) REFERENCES [dbo].[OrdiniErogatiSottoStati] ([Codice]),
    CONSTRAINT [FK_OrdiniErogatiTestate_OrdiniErogatiStati] FOREIGN KEY ([StatoOrderEntry]) REFERENCES [dbo].[OrdiniErogatiStati] ([Codice]),
    CONSTRAINT [FK_OrdiniErogatiTestate_OrdiniErogatiStatiRisposta] FOREIGN KEY ([StatoRisposta]) REFERENCES [dbo].[OrdiniErogatiStatiRisposta] ([Codice]),
    CONSTRAINT [FK_OrdiniErogatiTestate_OrdiniTestate] FOREIGN KEY ([IDOrdineTestata]) REFERENCES [dbo].[OrdiniTestate] ([ID]),
    CONSTRAINT [FK_OrdiniErogatiTestate_Sistemi_Erogante] FOREIGN KEY ([IDSistemaErogante]) REFERENCES [dbo].[Sistemi] ([ID]),
    CONSTRAINT [FK_OrdiniErogatiTestate_Sistemi_Richiedente] FOREIGN KEY ([IDSistemaRichiedente]) REFERENCES [dbo].[Sistemi] ([ID]),
    CONSTRAINT [FK_OrdiniErogatiTestate_Tickets_Inserimento] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID]),
    CONSTRAINT [FK_OrdiniErogatiTestate_Tickets_Modifica] FOREIGN KEY ([IDTicketModifica]) REFERENCES [dbo].[Tickets] ([ID])
);








GO



GO



GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Data operazione sul sistema erogante', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrdiniErogatiTestate', @level2type = N'COLUMN', @level2name = N'Data';


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[OrdiniErogatiTestate]([IDTicketModifica] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[OrdiniErogatiTestate]([IDTicketInserimento] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_StatoOrderEntry]
    ON [dbo].[OrdiniErogatiTestate]([StatoOrderEntry] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDSistemaRichiedente]
    ON [dbo].[OrdiniErogatiTestate]([IDSistemaRichiedente] ASC, [IDRichiestaRichiedente] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDSistemaErogante]
    ON [dbo].[OrdiniErogatiTestate]([IDSistemaErogante] ASC, [IDRichiestaErogante] ASC) WITH (FILLFACTOR = 70);


GO
CREATE CLUSTERED INDEX [IX_IDOrdineTestata]
    ON [dbo].[OrdiniErogatiTestate]([IDOrdineTestata] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_DataPrenotazione]
    ON [dbo].[OrdiniErogatiTestate]([DataPrenotazione] ASC)
    INCLUDE([IDOrdineTestata]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_DataModifica]
    ON [dbo].[OrdiniErogatiTestate]([DataModifica] ASC) WITH (FILLFACTOR = 70);

