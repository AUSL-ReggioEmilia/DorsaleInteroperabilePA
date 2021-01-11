CREATE TABLE [dbo].[AbbonamentiRepartiRichiedenti] (
    [Id]                                  UNIQUEIDENTIFIER CONSTRAINT [DF_AbbonamentiRepartiRichiedenti_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [IdUtenti]                            UNIQUEIDENTIFIER NOT NULL,
    [IdRepartiRichiedentiSistemiEroganti] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_RepartiRichiedentiAbbonamenti] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [IX_IdUtenti]
    ON [dbo].[AbbonamentiRepartiRichiedenti]([IdUtenti] ASC) WITH (FILLFACTOR = 95);

