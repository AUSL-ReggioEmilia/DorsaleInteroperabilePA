CREATE TABLE [codifiche].[ICD9TipoCodice] (
    [Id]          TINYINT       NOT NULL,
    [Descrizione] VARCHAR (256) NOT NULL,
    CONSTRAINT [PK_ICD9TipoCodice] PRIMARY KEY CLUSTERED ([Id] ASC)
);

