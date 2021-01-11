CREATE TABLE [dbo].[compress_OrdiniVersioni] (
    [ID]                       UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]          DATETIME2 (3)    NULL,
    [IDTicketInserimento]      UNIQUEIDENTIFIER NOT NULL,
    [IDOrdineTestata]          UNIQUEIDENTIFIER NOT NULL,
    [Tipo]                     TINYINT          NULL,
    [StatoOrderEntry]          VARCHAR (16)     NULL,
    [DatiVersione]             XML              NULL,
    [Data]                     DATETIME2 (0)    NULL,
    [DatiVersioneXmlCompresso] VARBINARY (MAX)  NULL,
    [StatoCompressione]        TINYINT          CONSTRAINT [DF_OrdiniVersioni_StatoCompressione] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_OrdiniVersioni] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);




GO
CREATE CLUSTERED INDEX [IXC_DataInserimento]
    ON [dbo].[compress_OrdiniVersioni]([DataInserimento] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_StatoCompressione]
    ON [dbo].[compress_OrdiniVersioni]([StatoCompressione] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[compress_OrdiniVersioni]([IDTicketInserimento] ASC) WITH (FILLFACTOR = 95);

