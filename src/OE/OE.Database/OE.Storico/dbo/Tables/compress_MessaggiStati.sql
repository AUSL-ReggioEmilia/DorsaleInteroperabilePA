CREATE TABLE [dbo].[compress_MessaggiStati] (
    [ID]                     UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]        DATETIME2 (3)    NULL,
    [DataModifica]           DATETIME2 (3)    NULL,
    [IDTicketInserimento]    UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]       UNIQUEIDENTIFIER NOT NULL,
    [IDOrdineErogatoTestata] UNIQUEIDENTIFIER NULL,
    [IDSistemaRichiedente]   UNIQUEIDENTIFIER NULL,
    [IDRichiestaRichiedente] VARCHAR (64)     NULL,
    [Messaggio]              XML              NULL,
    [Stato]                  TINYINT          NOT NULL,
    [Fault]                  XML              NULL,
    [StatoOrderEntry]        VARCHAR (16)     NULL,
    [TipoStato]              VARCHAR (8)      NULL,
    [DettaglioErrore]        VARCHAR (MAX)    NULL,
    [MessaggioXmlCompresso]  VARBINARY (MAX)  NULL,
    [StatoCompressione]      TINYINT          CONSTRAINT [DF_MessaggiStati_StatoCompressione] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_MessaggiStati] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);






GO
CREATE CLUSTERED INDEX [IXC_DataModifica]
    ON [dbo].[compress_MessaggiStati]([DataModifica] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDOrdineErogatoTestata]
    ON [dbo].[compress_MessaggiStati]([IDOrdineErogatoTestata] ASC, [IDSistemaRichiedente] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_StatoCompressione]
    ON [dbo].[compress_MessaggiStati]([StatoCompressione] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[compress_MessaggiStati]([IDTicketModifica] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[compress_MessaggiStati]([IDTicketInserimento] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDSistemaRichiedente]
    ON [dbo].[compress_MessaggiStati]([IDSistemaRichiedente] ASC) WITH (FILLFACTOR = 70);

