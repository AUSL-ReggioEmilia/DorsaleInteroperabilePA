CREATE TABLE [dbo].[TipiDocumentoFSE] (
    [Codice]      VARCHAR (64)  NOT NULL,
    [Descrizione] VARCHAR (128) NOT NULL,
    CONSTRAINT [PK_TipiDocumentoFSE] PRIMARY KEY CLUSTERED ([Codice] ASC)
);

