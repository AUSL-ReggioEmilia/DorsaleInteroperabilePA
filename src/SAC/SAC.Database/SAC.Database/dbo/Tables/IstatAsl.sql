CREATE TABLE [dbo].[IstatAsl] (
    [Codice]           VARCHAR (3)  NOT NULL,
    [CodiceComune]     VARCHAR (6)  NOT NULL,
    [Nome]             VARCHAR (64) NOT NULL,
    [CodiceAslRegione] VARCHAR (3)  NOT NULL,
    CONSTRAINT [PK_IstatAsl] PRIMARY KEY CLUSTERED ([Codice] ASC, [CodiceComune] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_IstatAsl_IstatComuni] FOREIGN KEY ([CodiceComune]) REFERENCES [dbo].[IstatComuni] ([Codice])
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[IstatAsl] TO [DataAccessSql]
    AS [dbo];

