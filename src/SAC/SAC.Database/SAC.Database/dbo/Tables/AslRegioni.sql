CREATE TABLE [dbo].[AslRegioni] (
    [Codice] VARCHAR (3)  NOT NULL,
    [Nome]   VARCHAR (64) NOT NULL,
    CONSTRAINT [PK_AslRegioni] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);

