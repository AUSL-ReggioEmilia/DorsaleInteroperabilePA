CREATE TABLE [dbo].[PazientiClassificazione] (
    [Id]              UNIQUEIDENTIFIER NOT NULL,
    [IdPazientiBase]  UNIQUEIDENTIFIER NOT NULL,
    [Classificazione] VARCHAR (128)    NOT NULL,
    CONSTRAINT [PK_PazientiClassificazione] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

