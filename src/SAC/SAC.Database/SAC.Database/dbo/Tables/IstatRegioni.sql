CREATE TABLE [dbo].[IstatRegioni] (
    [Codice]                 VARCHAR (2)  NOT NULL,
    [Nome]                   VARCHAR (64) NOT NULL,
    [RipartizioneGeografica] VARCHAR (64) NOT NULL,
    CONSTRAINT [PK_IstatRegioni] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[IstatRegioni] TO [DataAccessSql]
    AS [dbo];

