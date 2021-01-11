CREATE TABLE [dbo].[OrdiniErogatiSottoStati] (
    [Codice]      VARCHAR (16)  NOT NULL,
    [Descrizione] VARCHAR (128) NOT NULL,
    [Note]        VARCHAR (256) NULL,
    [Ordinamento] TINYINT       NOT NULL,
    CONSTRAINT [PK_OrdiniErogatiSottoStati] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);

