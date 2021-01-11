CREATE TABLE [dbo].[compress_MessaggiRichieste] (
    [ID]                     UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]        DATETIME2 (3)    NULL,
    [DataModifica]           DATETIME2 (3)    NULL,
    [IDTicketInserimento]    UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]       UNIQUEIDENTIFIER NOT NULL,
    [IDOrdineTestata]        UNIQUEIDENTIFIER NULL,
    [IDSistemaRichiedente]   UNIQUEIDENTIFIER NULL,
    [IDRichiestaRichiedente] VARCHAR (64)     NULL,
    [Messaggio]              XML              NULL,
    [Stato]                  TINYINT          NOT NULL,
    [Fault]                  XML              NULL,
    [StatoOrderEntry]        VARCHAR (16)     NULL,
    [DettaglioErrore]        VARCHAR (MAX)    NULL,
    [MessaggioXmlCompresso]  VARBINARY (MAX)  NULL,
    [StatoCompressione]      TINYINT          CONSTRAINT [DF_MessaggiRichieste_StatoCompressione] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_MessaggiRichieste] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);






GO
CREATE CLUSTERED INDEX [IXC_DataModifica]
    ON [dbo].[compress_MessaggiRichieste]([DataModifica] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDOrdiniTestata]
    ON [dbo].[compress_MessaggiRichieste]([IDOrdineTestata] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_StatoCompressione]
    ON [dbo].[compress_MessaggiRichieste]([StatoCompressione] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[compress_MessaggiRichieste]([IDTicketModifica] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[compress_MessaggiRichieste]([IDTicketInserimento] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDSistemaRichiedente]
    ON [dbo].[compress_MessaggiRichieste]([IDSistemaRichiedente] ASC) WITH (FILLFACTOR = 70);

