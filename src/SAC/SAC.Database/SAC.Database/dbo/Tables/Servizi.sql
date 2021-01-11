CREATE TABLE [dbo].[Servizi] (
    [Id]          TINYINT       NOT NULL,
    [Nome]        VARCHAR (64)  NULL,
    [Descrizione] VARCHAR (128) NULL,
    CONSTRAINT [PK_Servizi] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

