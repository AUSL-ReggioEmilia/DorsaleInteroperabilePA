CREATE TABLE [dbo].[OrdiniRigheRichieste] (
    [ID]                  UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]     DATETIME2 (3)    NOT NULL,
    [DataModifica]        DATETIME2 (3)    NOT NULL,
    [IDTicketInserimento] UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]    UNIQUEIDENTIFIER NOT NULL,
    [IDOrdineTestata]     UNIQUEIDENTIFIER NOT NULL,
    [StatoOrderEntry]     VARCHAR (16)     NULL,
    [DataModificaStato]   DATETIME2 (0)    NULL,
    [IDPrestazione]       UNIQUEIDENTIFIER NOT NULL,
    [IDSistemaErogante]   UNIQUEIDENTIFIER NOT NULL,
    [IDRigaOrderEntry]    VARCHAR (64)     NULL,
    [IDRigaRichiedente]   VARCHAR (64)     NULL,
    [IDRigaErogante]      VARCHAR (64)     NULL,
    [IDRichiestaErogante] VARCHAR (64)     NULL,
    [StatoRichiedente]    XML              NULL,
    [Consensi]            XML              NULL,
    CONSTRAINT [PK_OrdiniRigheRichieste] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);




GO
CREATE CLUSTERED INDEX [IXC_DataModifica]
    ON [dbo].[OrdiniRigheRichieste]([DataModifica] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_StatoOrderEntry]
    ON [dbo].[OrdiniRigheRichieste]([StatoOrderEntry] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IdTestata_DataModifica]
    ON [dbo].[OrdiniRigheRichieste]([IDOrdineTestata] ASC, [DataModifica] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDPrestazione]
    ON [dbo].[OrdiniRigheRichieste]([IDPrestazione] ASC)
    INCLUDE([DataModifica], [IDOrdineTestata]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDSistemaErogante]
    ON [dbo].[OrdiniRigheRichieste]([IDSistemaErogante] ASC, [IDOrdineTestata] ASC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_DataInserimento]
    ON [dbo].[OrdiniRigheRichieste]([DataInserimento] ASC) WITH (FILLFACTOR = 70);

