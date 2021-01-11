CREATE TABLE [dbo].[OrdiniSottoStati] (
    [Codice]      VARCHAR (16)  NOT NULL,
    [Descrizione] VARCHAR (128) NOT NULL,
    [Note]        VARCHAR (256) NULL,
    [Ordinamento] TINYINT       NOT NULL,
    CONSTRAINT [PK_OrdiniSottoStati] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);

