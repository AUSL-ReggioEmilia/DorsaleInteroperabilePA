CREATE TABLE [dbo].[StampeSottoscrizioniCoda] (
    [Id]                      UNIQUEIDENTIFIER CONSTRAINT [DF_StampeSottoscrizioniCoda_Id] DEFAULT (newid()) NOT NULL,
    [Ts]                      ROWVERSION       NOT NULL,
    [DataInserimento]         DATETIME         CONSTRAINT [DF_StampeSottoscrizioniCoda_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]            DATETIME         CONSTRAINT [DF_StampeSottoscrizioniCoda_DataModifica] DEFAULT (getdate()) NOT NULL,
    [IdStampeSottoscrizioni]  UNIQUEIDENTIFIER NOT NULL,
    [IdReferto]               UNIQUEIDENTIFIER NOT NULL,
    [DataModificaReferto]     DATETIME         NOT NULL,
    [Errore]                  VARCHAR (2048)   NULL,
    [DataSottomissione]       DATETIME         NULL,
    [CounterModificheReferto] INT              CONSTRAINT [DF_StampeSottoscrizioniCoda_CounterModificheReferto] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_StatoStampa] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_StampeSottoscrizioniCoda_StampeSottoscrizioniCoda] FOREIGN KEY ([IdStampeSottoscrizioni]) REFERENCES [dbo].[StampeSottoscrizioni] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_IdStampeSottoscrizioniCoda_IdStampeSottoscrizioni_DataDimissione]
    ON [dbo].[StampeSottoscrizioniCoda]([IdStampeSottoscrizioni] ASC, [DataSottomissione] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_StampeSottoscrizioniCoda]
    ON [dbo].[StampeSottoscrizioniCoda]([DataInserimento] ASC) WITH (FILLFACTOR = 95);

