CREATE TABLE [dbo].[compress_OrdiniErogatiVersioni] (
    [ID]                       UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]          DATETIME2 (3)    NULL,
    [IDTicketInserimento]      UNIQUEIDENTIFIER NOT NULL,
    [IDOrdineErogatoTestata]   UNIQUEIDENTIFIER NOT NULL,
    [StatoOrderEntry]          VARCHAR (16)     NULL,
    [DatiVersione]             XML              NULL,
    [DatiVersioneXmlCompresso] VARBINARY (MAX)  NULL,
    [StatoCompressione]        TINYINT          CONSTRAINT [DF_OrdiniErogatiVersioni_StatoCompressione] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_OrdiniErogatiVersioni] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);




GO
CREATE CLUSTERED INDEX [IXC_DataInserimento]
    ON [dbo].[compress_OrdiniErogatiVersioni]([DataInserimento] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_StatoCompressione]
    ON [dbo].[compress_OrdiniErogatiVersioni]([StatoCompressione] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[compress_OrdiniErogatiVersioni]([IDTicketInserimento] ASC) WITH (FILLFACTOR = 95);

