CREATE TABLE [codifiche].[FarmaMonografieFoglietti] (
    [Id]                     UNIQUEIDENTIFIER CONSTRAINT [DF_FarmaMonografieFoglietti_Id] DEFAULT (newsequentialid()) NOT NULL,
    [CodiceMonografia]       INT              NOT NULL,
    [CodiceSezione]          VARCHAR (16)     NOT NULL,
    [NumeroProgressivoLinea] SMALLINT         NOT NULL,
    [TestoDellaLinea]        VARCHAR (70)     NULL,
    [DataInserimento]        DATETIME         CONSTRAINT [DF_FarmaMonografieFoglietti_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]           DATETIME         CONSTRAINT [DF_FarmaMonografieFoglietti_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento]      VARCHAR (128)    CONSTRAINT [DF_FarmaMonografieFoglietti_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]         VARCHAR (128)    CONSTRAINT [DF_FarmaMonografieFoglietti_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_FarmaMonografieFoglietti] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_CodiceSezioneLinea]
    ON [codifiche].[FarmaMonografieFoglietti]([CodiceMonografia] ASC, [CodiceSezione] ASC, [NumeroProgressivoLinea] ASC);

