CREATE TABLE [dbo].[RefertiClassificazione] (
    [Id]              UNIQUEIDENTIFIER NOT NULL,
    [IdRefertiBase]   UNIQUEIDENTIFIER NOT NULL,
    [Classificazione] VARCHAR (128)    NOT NULL,
    CONSTRAINT [PK_RefertiClassificazione] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [IX_RefertiClassificazioneIdRefertiBase]
    ON [dbo].[RefertiClassificazione]([Classificazione] ASC, [IdRefertiBase] ASC) WITH (FILLFACTOR = 95);

