CREATE TABLE [dbo].[RepartiRichiedentiSistemiEroganti] (
    [Id]                            UNIQUEIDENTIFIER CONSTRAINT [DF_RepartiRichiedentiSistemiEroganti_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [IdSistemaErogante]             UNIQUEIDENTIFIER NULL,
    [IdRepartiRichiedenti]          UNIQUEIDENTIFIER NULL,
    [RepartoRichiedenteCodice]      VARCHAR (16)     NULL,
    [RepartoRichiedenteDescrizione] VARCHAR (128)    NULL,
    CONSTRAINT [PK_RepartiRichiedentiSistemiEroganti] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_RepartiRichiedentiSistemiEroganti_RepartiRichiedenti] FOREIGN KEY ([IdRepartiRichiedenti]) REFERENCES [dbo].[RepartiRichiedenti] ([Id]),
    CONSTRAINT [FK_RepartiRichiedentiSistemiEroganti_SistemiEroganti] FOREIGN KEY ([IdSistemaErogante]) REFERENCES [dbo].[SistemiEroganti] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_RepartiRichiedentiSistemiEroganti]
    ON [dbo].[RepartiRichiedentiSistemiEroganti]([IdSistemaErogante] ASC, [RepartoRichiedenteCodice] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IdRepartiRichiedenti]
    ON [dbo].[RepartiRichiedentiSistemiEroganti]([IdRepartiRichiedenti] ASC)
    INCLUDE([IdSistemaErogante]) WITH (FILLFACTOR = 95);

