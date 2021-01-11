CREATE TABLE [dbo].[Aziende] (
    [Codice]      VARCHAR (16)  NOT NULL,
    [Descrizione] VARCHAR (128) NULL,
    CONSTRAINT [PK_Aziende] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);

