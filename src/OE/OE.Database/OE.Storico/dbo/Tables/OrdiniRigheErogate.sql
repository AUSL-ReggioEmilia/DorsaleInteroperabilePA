CREATE TABLE [dbo].[OrdiniRigheErogate] (
    [ID]                     UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]        DATETIME2 (3)    NOT NULL,
    [DataModifica]           DATETIME2 (3)    NOT NULL,
    [IDTicketInserimento]    UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]       UNIQUEIDENTIFIER NOT NULL,
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
    CONSTRAINT [PK_OrdiniRigheErogate] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);




GO
CREATE CLUSTERED INDEX [IXC_DataModifica]
    ON [dbo].[OrdiniRigheErogate]([DataModifica] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDOrdineErogatoTestata]
    ON [dbo].[OrdiniRigheErogate]([IDOrdineErogatoTestata] ASC, [IDRigaErogante] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_RigaErogante]
    ON [dbo].[OrdiniRigheErogate]([IDOrdineErogatoTestata] ASC, [IDRigaErogante] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_RigaRichiedente]
    ON [dbo].[OrdiniRigheErogate]([IDOrdineErogatoTestata] ASC, [IDRigaRichiedente] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_DataInserimento]
    ON [dbo].[OrdiniRigheErogate]([DataInserimento] ASC) WITH (FILLFACTOR = 70);

