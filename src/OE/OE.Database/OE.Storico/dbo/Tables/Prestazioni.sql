CREATE TABLE [dbo].[Prestazioni] (
    [ID]                        UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]           DATETIME2 (0)    NOT NULL,
    [DataModifica]              DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento]       UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]          UNIQUEIDENTIFIER NOT NULL,
    [TS]                        VARBINARY (8)    NOT NULL,
    [Codice]                    VARCHAR (16)     NOT NULL,
    [Descrizione]               VARCHAR (256)    NULL,
    [Tipo]                      TINYINT          NOT NULL,
    [Provenienza]               TINYINT          NULL,
    [IDSistemaErogante]         UNIQUEIDENTIFIER NOT NULL,
    [Attivo]                    BIT              NOT NULL,
    [UtenteInserimento]         VARCHAR (64)     NOT NULL,
    [UtenteModifica]            VARCHAR (64)     NOT NULL,
    [CodiceSinonimo]            VARCHAR (16)     NULL,
    [Note]                      VARCHAR (1024)   NULL,
    [RichiedibileSoloDaProfilo] BIT              NOT NULL,
    CONSTRAINT [PK_Prestazioni] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);




GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[Prestazioni]([IDTicketInserimento] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[Prestazioni]([IDTicketModifica] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_SistemaErogante]
    ON [dbo].[Prestazioni]([IDSistemaErogante] ASC) WITH (FILLFACTOR = 70);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CodiceSistema]
    ON [dbo].[Prestazioni]([Codice] ASC, [IDSistemaErogante] ASC) WITH (FILLFACTOR = 70);

