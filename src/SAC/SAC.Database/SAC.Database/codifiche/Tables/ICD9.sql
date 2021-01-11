CREATE TABLE [codifiche].[ICD9] (
    [Id]                UNIQUEIDENTIFIER CONSTRAINT [DF_ICD9_IDU] DEFAULT (newsequentialid()) NOT NULL,
    [Codice]            VARCHAR (16)     NOT NULL,
    [Descrizione]       VARCHAR (256)    NULL,
    [IdTipoCodice]      TINYINT          NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_ICD9_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_ICD9_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_ICD9_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_ICD9_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_ICD9] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ICD9_ICD9TipoCodice] FOREIGN KEY ([IdTipoCodice]) REFERENCES [codifiche].[ICD9TipoCodice] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_CODICE]
    ON [codifiche].[ICD9]([Codice] ASC, [IdTipoCodice] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DESCRIZIONE]
    ON [codifiche].[ICD9]([Descrizione] ASC, [IdTipoCodice] ASC);

