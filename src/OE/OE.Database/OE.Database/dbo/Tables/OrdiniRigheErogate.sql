CREATE TABLE [dbo].[OrdiniRigheErogate] (
    [ID]                     UNIQUEIDENTIFIER CONSTRAINT [DF_OrdiniRigheErogate_ID] DEFAULT (newid()) NOT NULL,
    [DataInserimento]        DATETIME2 (0)    CONSTRAINT [DF_OrdiniRigheErogate_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]           DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento]    UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]       UNIQUEIDENTIFIER NOT NULL,
    [TS]                     ROWVERSION       NOT NULL,
    [IDOrdineErogatoTestata] UNIQUEIDENTIFIER NOT NULL,
    [StatoOrderEntry]        VARCHAR (16)     NOT NULL,
    [DataModificaStato]      DATETIME2 (0)    NULL,
    [IDPrestazione]          UNIQUEIDENTIFIER NOT NULL,
    [IDRigaRichiedente]      VARCHAR (64)     NULL,
    [IDRigaErogante]         VARCHAR (64)     NULL,
    [StatoErogante]          XML              NOT NULL,
    [Data]                   DATETIME2 (0)    NULL,
    [Operatore]              XML              NULL,
    [Consensi]               XML              NULL,
    CONSTRAINT [PK_OrdiniRigheErogate] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_OrdiniRigheErogate_OrdiniErogatiTestate] FOREIGN KEY ([IDOrdineErogatoTestata]) REFERENCES [dbo].[OrdiniErogatiTestate] ([ID]),
    CONSTRAINT [FK_OrdiniRigheErogate_OrdiniRigheErogateStati] FOREIGN KEY ([StatoOrderEntry]) REFERENCES [dbo].[OrdiniRigheErogateStati] ([Codice]),
    CONSTRAINT [FK_OrdiniRigheErogate_Prestazioni] FOREIGN KEY ([IDPrestazione]) REFERENCES [dbo].[Prestazioni] ([ID]),
    CONSTRAINT [FK_OrdiniRigheErogate_Tickets_Inserimento] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID]),
    CONSTRAINT [FK_OrdiniRigheErogate_Tickets_Modifica] FOREIGN KEY ([IDTicketModifica]) REFERENCES [dbo].[Tickets] ([ID])
);






GO
CREATE CLUSTERED INDEX [IXC_DataInserimento]
    ON [dbo].[OrdiniRigheErogate]([DataInserimento] ASC, [ID] ASC) WITH (FILLFACTOR = 95);


GO



GO



GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[OrdiniRigheErogate]([IDTicketModifica] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[OrdiniRigheErogate]([IDTicketInserimento] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RigaRichiedente]
    ON [dbo].[OrdiniRigheErogate]([IDOrdineErogatoTestata] ASC, [IDRigaRichiedente] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_RigaErogante]
    ON [dbo].[OrdiniRigheErogate]([IDOrdineErogatoTestata] ASC, [IDRigaErogante] ASC) WITH (FILLFACTOR = 70);

