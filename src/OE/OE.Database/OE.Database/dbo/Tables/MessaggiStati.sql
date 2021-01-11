CREATE TABLE [dbo].[MessaggiStati] (
    [ID]                     UNIQUEIDENTIFIER DEFAULT (newsequentialid()) NOT NULL,
    [DataInserimento]        DATETIME2 (0)    NOT NULL,
    [DataModifica]           DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento]    UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]       UNIQUEIDENTIFIER NOT NULL,
    [IDOrdineErogatoTestata] UNIQUEIDENTIFIER NULL,
    [IDSistemaRichiedente]   UNIQUEIDENTIFIER NULL,
    [IDRichiestaRichiedente] VARCHAR (64)     NULL,
    [Messaggio]              XML              NOT NULL,
    [Stato]                  TINYINT          NOT NULL,
    [Fault]                  XML              NULL,
    [StatoOrderEntry]        VARCHAR (16)     NULL,
    [TipoStato]              VARCHAR (8)      NULL,
    [DettaglioErrore]        VARCHAR (MAX)    NULL,
    CONSTRAINT [PK_MessaggiStati] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_MessaggiStati_OrdiniErogatiTestate] FOREIGN KEY ([IDOrdineErogatoTestata]) REFERENCES [dbo].[OrdiniErogatiTestate] ([ID]),
    CONSTRAINT [FK_MessaggiStati_Sistemi_Richiedente] FOREIGN KEY ([IDSistemaRichiedente]) REFERENCES [dbo].[Sistemi] ([ID]),
    CONSTRAINT [FK_MessaggiStati_Tickets_Inserimento] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID]),
    CONSTRAINT [FK_MessaggiStati_Tickets_Modifica] FOREIGN KEY ([IDTicketModifica]) REFERENCES [dbo].[Tickets] ([ID])
);








GO
CREATE UNIQUE CLUSTERED INDEX [IXC_MessaggiStati]
    ON [dbo].[MessaggiStati]([DataInserimento] ASC, [ID] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IDOrdineErogatoTestata]
    ON [dbo].[MessaggiStati]([IDOrdineErogatoTestata] ASC, [IDSistemaRichiedente] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Inserito; 1=Processato; 2=Errore;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MessaggiStati', @level2type = N'COLUMN', @level2name = N'Stato';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'RR; OSU', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MessaggiStati', @level2type = N'COLUMN', @level2name = N'TipoStato';


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[MessaggiStati]([IDTicketModifica] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[MessaggiStati]([IDTicketInserimento] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDSistemaRichiedente]
    ON [dbo].[MessaggiStati]([IDSistemaRichiedente] ASC) WITH (FILLFACTOR = 70);

