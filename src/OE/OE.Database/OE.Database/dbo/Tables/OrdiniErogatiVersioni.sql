CREATE TABLE [dbo].[OrdiniErogatiVersioni] (
    [ID]                       UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]          DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento]      UNIQUEIDENTIFIER NOT NULL,
    [IDOrdineErogatoTestata]   UNIQUEIDENTIFIER NOT NULL,
    [StatoOrderEntry]          VARCHAR (16)     NULL,
    [DatiVersione]             XML              NOT NULL,
    [DatiVersioneXmlCompresso] VARBINARY (MAX)  NULL,
    [StatoCompressione]        TINYINT          CONSTRAINT [DF_OrdiniErogatiVersioni_StatoCompressione] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_OrdiniErogatiVersioni] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_OrdiniErogatiVersioni_OrdiniErogatiStati] FOREIGN KEY ([StatoOrderEntry]) REFERENCES [dbo].[OrdiniErogatiStati] ([Codice]),
    CONSTRAINT [FK_OrdiniErogatiVersioni_OrdiniErogatiTestate] FOREIGN KEY ([IDOrdineErogatoTestata]) REFERENCES [dbo].[OrdiniErogatiTestate] ([ID]),
    CONSTRAINT [FK_OrdiniErogatiVersioni_Tickets] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID])
);






GO



GO
CREATE NONCLUSTERED INDEX [IX_IDOrdineErogatoTestata]
    ON [dbo].[OrdiniErogatiVersioni]([IDOrdineErogatoTestata] ASC)
    INCLUDE([ID]);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[OrdiniErogatiVersioni]([IDTicketInserimento] ASC);


GO
CREATE CLUSTERED INDEX [IXC_IDOrdineErogatoTestata]
    ON [dbo].[OrdiniErogatiVersioni]([DataInserimento] ASC, [IDOrdineErogatoTestata] ASC) WITH (FILLFACTOR = 70);

