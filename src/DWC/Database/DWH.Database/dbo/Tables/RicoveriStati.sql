CREATE TABLE [dbo].[RicoveriStati] (
    [Id]          TINYINT      NOT NULL,
    [Descrizione] VARCHAR (64) NOT NULL,
    CONSTRAINT [PK_RicoveriStati] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

