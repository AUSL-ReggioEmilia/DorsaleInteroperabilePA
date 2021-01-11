CREATE TABLE [dbo].[IstatProvince] (
    [Codice]        VARCHAR (3)  NOT NULL,
    [Nome]          VARCHAR (64) NOT NULL,
    [Sigla]         VARCHAR (2)  NOT NULL,
    [CodiceRegione] VARCHAR (2)  NOT NULL,
    CONSTRAINT [PK_IstatProvince] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_IstatProvince_IstatRegioni] FOREIGN KEY ([CodiceRegione]) REFERENCES [dbo].[IstatRegioni] ([Codice])
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[IstatProvince] TO [DataAccessSql]
    AS [dbo];

