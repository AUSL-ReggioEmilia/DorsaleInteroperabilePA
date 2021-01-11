CREATE TABLE [dbo].[StampeSottoscrizioniDocumentiCoda] (
    [Id]                         UNIQUEIDENTIFIER CONSTRAINT [DF_StampeSottoscrizioniDocumentiCoda_Id] DEFAULT (newid()) NOT NULL,
    [Ts]                         ROWVERSION       NOT NULL,
    [DataInserimento]            DATETIME         CONSTRAINT [DF_StampeSottoscrizioniDocumentiCoda_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]               DATETIME         CONSTRAINT [DF_StampeSottoscrizioniDocumentiCoda_DataModifica] DEFAULT (getdate()) NOT NULL,
    [IdStampeSottoscrizioniCoda] UNIQUEIDENTIFIER NOT NULL,
    [HashDocumento]              IMAGE            NULL,
    [IdJob]                      UNIQUEIDENTIFIER NOT NULL,
    [DataSottomissione]          DATETIME         NOT NULL,
    [Stato]                      INT              NOT NULL,
    [Errore]                     VARCHAR (2048)   NULL,
    CONSTRAINT [PK_StampeSottoscrizioniDocumentiCoda] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_StampeSottoscrizioniDocumentiCoda_StampeSottoscrizioniCoda] FOREIGN KEY ([IdStampeSottoscrizioniCoda]) REFERENCES [dbo].[StampeSottoscrizioniCoda] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_StampeSottoscrizioniDocumentiCoda_IdStampeSottoscrizioniCoda]
    ON [dbo].[StampeSottoscrizioniDocumentiCoda]([IdStampeSottoscrizioniCoda] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_StampeSottoscrizioniDocumentiCoda_Stato]
    ON [dbo].[StampeSottoscrizioniDocumentiCoda]([Stato] ASC) WITH (FILLFACTOR = 95);

