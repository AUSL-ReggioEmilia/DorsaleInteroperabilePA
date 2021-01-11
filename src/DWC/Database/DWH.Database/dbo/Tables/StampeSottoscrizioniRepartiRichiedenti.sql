CREATE TABLE [dbo].[StampeSottoscrizioniRepartiRichiedenti] (
    [Id]                                  UNIQUEIDENTIFIER CONSTRAINT [DF_StampeSottoscrizioniRepartiRichiedenti_Id] DEFAULT (newid()) NOT NULL,
    [IdStampeSottoscrizioni]              UNIQUEIDENTIFIER NOT NULL,
    [IdRepartiRichiedentiSistemiEroganti] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_StampeSottoscrizioniRepartiRichiedenti] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_StampeSottoscrizioniRepartiRichiedenti_RepartiRichiedentiSistemiEroganti] FOREIGN KEY ([IdRepartiRichiedentiSistemiEroganti]) REFERENCES [dbo].[RepartiRichiedentiSistemiEroganti] ([Id]),
    CONSTRAINT [FK_StampeSottoscrizioniRepartiRichiedenti_StampeSottoscrizioni] FOREIGN KEY ([IdStampeSottoscrizioni]) REFERENCES [dbo].[StampeSottoscrizioni] ([Id])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_StampeSottoscrizioniRepartiRichiedenti]
    ON [dbo].[StampeSottoscrizioniRepartiRichiedenti]([IdStampeSottoscrizioni] ASC, [IdRepartiRichiedentiSistemiEroganti] ASC) WITH (FILLFACTOR = 95);

