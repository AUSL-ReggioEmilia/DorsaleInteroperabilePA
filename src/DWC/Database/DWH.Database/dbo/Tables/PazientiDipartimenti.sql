CREATE TABLE [dbo].[PazientiDipartimenti] (
    [ID]                     UNIQUEIDENTIFIER CONSTRAINT [DF_PazienteDipartimento_ID] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [IdPazientiBase]         UNIQUEIDENTIFIER NOT NULL,
    [IdPazienteDipartimento] VARCHAR (64)     NOT NULL,
    [ModalitaAssociazione]   TINYINT          NULL,
    CONSTRAINT [PK_PazienteDipartimento] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiDipartimenti_IdEsterno]
    ON [dbo].[PazientiDipartimenti]([IdPazienteDipartimento] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiDipartimenti_IdPazBase]
    ON [dbo].[PazientiDipartimenti]([IdPazientiBase] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [FK_PazientiDipartimenti_IdPazBase]
    ON [dbo].[PazientiDipartimenti]([IdPazientiBase] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiDipartimenti_IdEsternoPaziente]
    ON [dbo].[PazientiDipartimenti]([IdPazienteDipartimento] ASC) WITH (FILLFACTOR = 95);

