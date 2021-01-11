CREATE TABLE [dbo].[MessaggiRichieste] (
    [ID]                     UNIQUEIDENTIFIER DEFAULT (newsequentialid()) NOT NULL,
    [DataInserimento]        DATETIME2 (0)    NOT NULL,
    [DataModifica]           DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento]    UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]       UNIQUEIDENTIFIER NOT NULL,
    [IDOrdineTestata]        UNIQUEIDENTIFIER NULL,
    [IDSistemaRichiedente]   UNIQUEIDENTIFIER NULL,
    [IDRichiestaRichiedente] VARCHAR (64)     NULL,
    [Messaggio]              XML              NOT NULL,
    [Stato]                  TINYINT          NOT NULL,
    [Fault]                  XML              NULL,
    [StatoOrderEntry]        VARCHAR (16)     NULL,
    [DettaglioErrore]        VARCHAR (MAX)    NULL,
    CONSTRAINT [PK_MessaggiRichieste] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_MessaggiRichieste_OrdiniTestate] FOREIGN KEY ([IDOrdineTestata]) REFERENCES [dbo].[OrdiniTestate] ([ID]),
    CONSTRAINT [FK_MessaggiRichieste_Sistemi_Richiedente] FOREIGN KEY ([IDSistemaRichiedente]) REFERENCES [dbo].[Sistemi] ([ID]),
    CONSTRAINT [FK_MessaggiRichieste_Tickets_Inserimento] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID]),
    CONSTRAINT [FK_MessaggiRichieste_Tickets_Modifica] FOREIGN KEY ([IDTicketModifica]) REFERENCES [dbo].[Tickets] ([ID])
);








GO
CREATE UNIQUE CLUSTERED INDEX [IXC_MessaggiRichieste]
    ON [dbo].[MessaggiRichieste]([DataInserimento] ASC, [ID] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IDOrdiniTestata]
    ON [dbo].[MessaggiRichieste]([IDOrdineTestata] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IDRichiestaRichiedente]
    ON [dbo].[MessaggiRichieste]([IDRichiestaRichiedente] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Inserito; 1=Processato; 2=Errore;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MessaggiRichieste', @level2type = N'COLUMN', @level2name = N'Stato';


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[MessaggiRichieste]([IDTicketModifica] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[MessaggiRichieste]([IDTicketInserimento] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDSistemaRichiedente]
    ON [dbo].[MessaggiRichieste]([IDSistemaRichiedente] ASC) WITH (FILLFACTOR = 70);

