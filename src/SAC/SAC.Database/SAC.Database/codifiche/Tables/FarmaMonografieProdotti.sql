CREATE TABLE [codifiche].[FarmaMonografieProdotti] (
    [Id]                UNIQUEIDENTIFIER CONSTRAINT [DF_FarmaMonografieProdotti_Id] DEFAULT (newsequentialid()) NOT NULL,
    [CodiceProdotto]    VARCHAR (16)     NOT NULL,
    [CodiceMonografia]  INT              NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_FarmaMonografieProdotti_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_FarmaMonografieProdotti_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_FarmaMonografieProdotti_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_FarmaMonografieProdotti_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_FarmaMonografieProdotti] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO
CREATE CLUSTERED INDEX [IX_ProdottoMonografia]
    ON [codifiche].[FarmaMonografieProdotti]([CodiceProdotto] ASC, [CodiceMonografia] ASC);

