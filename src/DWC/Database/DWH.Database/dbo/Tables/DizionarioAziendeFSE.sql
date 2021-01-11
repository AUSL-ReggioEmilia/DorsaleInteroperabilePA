CREATE TABLE [dbo].[DizionarioAziendeFSE] (
    [Codice]      VARCHAR (6)   NOT NULL,
    [Descrizione] VARCHAR (128) NOT NULL,
    CONSTRAINT [PK_DizionarioAziendeFSE] PRIMARY KEY CLUSTERED ([Codice] ASC)
);

