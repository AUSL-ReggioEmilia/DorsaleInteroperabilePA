CREATE TABLE [organigramma].[UnitaOperativeRegimi] (
    [Id]                UNIQUEIDENTIFIER CONSTRAINT [DF_UnitaOperativeRegimi_Id] DEFAULT (newsequentialid()) NOT NULL,
    [IdUnitaOperativa]  UNIQUEIDENTIFIER NOT NULL,
    [CodiceRegime]      VARCHAR (16)     NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_UnitaOperativeRegimi_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_UnitaOperativeRegimi_DataModifica] DEFAULT (getdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_UnitaOperativeRegimi_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_UnitaOperativeRegimi_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_UnitaOperativeRegimi] PRIMARY KEY NONCLUSTERED ([Id] ASC),
    CONSTRAINT [FK_UnitaOperativeRegimi_Regimi] FOREIGN KEY ([CodiceRegime]) REFERENCES [organigramma].[Regimi] ([Codice]),
    CONSTRAINT [FK_UnitaOperativeRegimi_UnitaOperative] FOREIGN KEY ([IdUnitaOperativa]) REFERENCES [organigramma].[UnitaOperative] ([ID])
);


GO
CREATE UNIQUE CLUSTERED INDEX [IXU_UnitaOperativaRegime]
    ON [organigramma].[UnitaOperativeRegimi]([IdUnitaOperativa] ASC, [CodiceRegime] ASC);

