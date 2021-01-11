CREATE TABLE [dbo].[Priorita] (
    [Codice]      VARCHAR (16) NOT NULL,
    [Descrizione] VARCHAR (64) NOT NULL,
    CONSTRAINT [PK_Priorita] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);

