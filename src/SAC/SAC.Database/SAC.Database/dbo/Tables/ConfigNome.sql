CREATE TABLE [dbo].[ConfigNome] (
    [Nome]        VARCHAR (128)  NOT NULL,
    [Descrizione] VARCHAR (1024) NULL,
    CONSTRAINT [PK_ConfigNome] PRIMARY KEY CLUSTERED ([Nome] ASC) WITH (FILLFACTOR = 95)
);

