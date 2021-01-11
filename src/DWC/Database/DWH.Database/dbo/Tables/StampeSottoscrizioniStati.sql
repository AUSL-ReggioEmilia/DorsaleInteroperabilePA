CREATE TABLE [dbo].[StampeSottoscrizioniStati] (
    [Id]          INT          NOT NULL,
    [Descrizione] VARCHAR (64) NULL,
    CONSTRAINT [PK_StampeSottoscrizioniStati] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

