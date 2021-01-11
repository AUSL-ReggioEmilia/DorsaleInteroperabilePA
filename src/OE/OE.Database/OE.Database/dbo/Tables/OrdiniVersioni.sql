CREATE TABLE [dbo].[OrdiniVersioni] (
    [ID]                       UNIQUEIDENTIFIER CONSTRAINT [DF_OrdiniVersioni_ID] DEFAULT (newid()) NOT NULL,
    [DataInserimento]          DATETIME2 (0)    CONSTRAINT [DF_OrdiniVersioni_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [IDTicketInserimento]      UNIQUEIDENTIFIER NOT NULL,
    [IDOrdineTestata]          UNIQUEIDENTIFIER NOT NULL,
    [Tipo]                     TINYINT          NULL,
    [StatoOrderEntry]          VARCHAR (16)     NULL,
    [DatiVersione]             XML              NOT NULL,
    [Data]                     DATETIME2 (0)    NULL,
    [DatiVersioneXmlCompresso] VARBINARY (MAX)  NULL,
    [StatoCompressione]        TINYINT          CONSTRAINT [DF_OrdiniVersioni_StatoCompressione] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_OrdiniVersioni] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_OrdiniVersioni_OrdiniStati] FOREIGN KEY ([StatoOrderEntry]) REFERENCES [dbo].[OrdiniStati] ([Codice]),
    CONSTRAINT [FK_OrdiniVersioni_OrdiniTestate] FOREIGN KEY ([IDOrdineTestata]) REFERENCES [dbo].[OrdiniTestate] ([ID]),
    CONSTRAINT [FK_OrdiniVersioni_Tickets_Inserimento] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID])
);






GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Richiesta; 1=Stato;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrdiniVersioni', @level2type = N'COLUMN', @level2name = N'Tipo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Data di versione della richiesta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrdiniVersioni', @level2type = N'COLUMN', @level2name = N'Data';


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[OrdiniVersioni]([IDTicketInserimento] ASC);


GO
CREATE CLUSTERED INDEX [IXC_IDOrdineTestata]
    ON [dbo].[OrdiniVersioni]([DataInserimento] ASC, [IDOrdineTestata] ASC) WITH (FILLFACTOR = 70);

