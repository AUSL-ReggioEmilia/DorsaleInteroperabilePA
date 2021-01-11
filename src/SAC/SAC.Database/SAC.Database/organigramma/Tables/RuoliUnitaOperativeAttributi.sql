CREATE TABLE [organigramma].[RuoliUnitaOperativeAttributi] (
    [ID]                    UNIQUEIDENTIFIER DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [IdRuoliUnitaOperative] UNIQUEIDENTIFIER NOT NULL,
    [CodiceAttributo]       VARCHAR (64)     NOT NULL,
    [Note]                  VARCHAR (128)    NULL,
    [DataInserimento]       DATETIME         CONSTRAINT [DF_RuoliUnitaOperativeAttributi_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]          DATETIME         CONSTRAINT [DF_RuoliUnitaOperativeAttributi_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento]     VARCHAR (128)    CONSTRAINT [DF_RuoliUnitaOperativeAttributi_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]        VARCHAR (128)    CONSTRAINT [DF_RuoliUnitaOperativeAttributi_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_RuoliUnitaOperativeAttributi] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_RuoliUnitaOperativeAttributi_Attributi] FOREIGN KEY ([CodiceAttributo]) REFERENCES [organigramma].[Attributi] ([Codice]),
    CONSTRAINT [FK_RuoliUnitaOperativeAttributi_RuoliUnitaOperative] FOREIGN KEY ([IdRuoliUnitaOperative]) REFERENCES [organigramma].[RuoliUnitaOperative] ([ID])
);


GO
CREATE UNIQUE CLUSTERED INDEX [IXU_IdRuoliUnitaOperative_CodiceAttributo]
    ON [organigramma].[RuoliUnitaOperativeAttributi]([IdRuoliUnitaOperative] ASC, [CodiceAttributo] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_CodiceAttributo]
    ON [organigramma].[RuoliUnitaOperativeAttributi]([CodiceAttributo] ASC) WITH (FILLFACTOR = 95);

