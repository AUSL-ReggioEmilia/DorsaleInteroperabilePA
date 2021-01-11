CREATE TABLE [dbo].[OrdiniRigheRichieste] (
    [ID]                  UNIQUEIDENTIFIER CONSTRAINT [DF_OrdiniRigheRichieste_ID] DEFAULT (newid()) NOT NULL,
    [DataInserimento]     DATETIME2 (0)    CONSTRAINT [DF_OrdiniRigheRichieste_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]        DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento] UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]    UNIQUEIDENTIFIER NOT NULL,
    [TS]                  ROWVERSION       NOT NULL,
    [IDOrdineTestata]     UNIQUEIDENTIFIER NOT NULL,
    [StatoOrderEntry]     VARCHAR (16)     NULL,
    [DataModificaStato]   DATETIME2 (0)    NULL,
    [IDPrestazione]       UNIQUEIDENTIFIER NOT NULL,
    [IDSistemaErogante]   UNIQUEIDENTIFIER NOT NULL,
    [IDRigaOrderEntry]    VARCHAR (64)     NULL,
    [IDRigaRichiedente]   VARCHAR (64)     CONSTRAINT [DF_OrdiniRigheRichieste_Eliminato] DEFAULT ((0)) NULL,
    [IDRigaErogante]      VARCHAR (64)     NULL,
    [IDRichiestaErogante] VARCHAR (64)     NULL,
    [StatoRichiedente]    XML              NULL,
    [Consensi]            XML              NULL,
    CONSTRAINT [PK_OrdiniRigheRichieste] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_OrdiniRigheRichieste_OrdiniRigheRichiesteStati] FOREIGN KEY ([StatoOrderEntry]) REFERENCES [dbo].[OrdiniRigheRichiesteStati] ([Codice]),
    CONSTRAINT [FK_OrdiniRigheRichieste_OrdiniTestate] FOREIGN KEY ([IDOrdineTestata]) REFERENCES [dbo].[OrdiniTestate] ([ID]),
    CONSTRAINT [FK_OrdiniRigheRichieste_Prestazioni] FOREIGN KEY ([IDPrestazione]) REFERENCES [dbo].[Prestazioni] ([ID]),
    CONSTRAINT [FK_OrdiniRigheRichieste_Sistemi] FOREIGN KEY ([IDSistemaErogante]) REFERENCES [dbo].[Sistemi] ([ID]),
    CONSTRAINT [FK_OrdiniRigheRichieste_Tickets_Inserimento] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID]),
    CONSTRAINT [FK_OrdiniRigheRichieste_Tickets_Modifica] FOREIGN KEY ([IDTicketModifica]) REFERENCES [dbo].[Tickets] ([ID])
);








GO
CREATE UNIQUE CLUSTERED INDEX [IXC_DataInserimento]
    ON [dbo].[OrdiniRigheRichieste]([DataInserimento] ASC, [ID] ASC) WITH (FILLFACTOR = 95);


GO



GO



GO



GO



GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[OrdiniRigheRichieste]([IDTicketModifica] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[OrdiniRigheRichieste]([IDTicketInserimento] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_StatoOrderEntry]
    ON [dbo].[OrdiniRigheRichieste]([StatoOrderEntry] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IdTestata_DataModifica]
    ON [dbo].[OrdiniRigheRichieste]([IDOrdineTestata] ASC, [DataModifica] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDSistemaErogante]
    ON [dbo].[OrdiniRigheRichieste]([IDSistemaErogante] ASC, [IDOrdineTestata] ASC)
    INCLUDE([ID]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDPrestazione]
    ON [dbo].[OrdiniRigheRichieste]([IDPrestazione] ASC)
    INCLUDE([DataModifica], [IDOrdineTestata]) WITH (FILLFACTOR = 70);

