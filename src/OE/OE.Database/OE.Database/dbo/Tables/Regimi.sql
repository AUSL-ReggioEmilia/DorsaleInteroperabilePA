CREATE TABLE [dbo].[Regimi] (
    [Codice]      VARCHAR (16) NOT NULL,
    [Descrizione] VARCHAR (64) NOT NULL,
    CONSTRAINT [PK_Regimi] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);

