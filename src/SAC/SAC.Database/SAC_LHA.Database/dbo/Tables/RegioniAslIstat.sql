CREATE TABLE [dbo].[RegioniAslIstat] (
    [CodiceASLRegione]      VARCHAR (3) NOT NULL,
    [CodiceIstatRegione]    VARCHAR (3) NOT NULL,
    [CodiceIstatRegioneOld] VARCHAR (2) NULL,
    CONSTRAINT [PK_RegioniAslIstat] PRIMARY KEY CLUSTERED ([CodiceASLRegione] ASC, [CodiceIstatRegione] ASC) WITH (FILLFACTOR = 95)
);

