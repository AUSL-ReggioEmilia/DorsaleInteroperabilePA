CREATE TABLE [organigramma].[RuoliUnitaOperative] (
    [ID]                UNIQUEIDENTIFIER DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [IdRuolo]           UNIQUEIDENTIFIER NOT NULL,
    [IdUnitaOperativa]  UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_RuoliUnitaOperative_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_RuoliUnitaOperative_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_RuoliUnitaOperative_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_RuoliUnitaOperative_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_RuoliUnitaOperative] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_RuoliUnitaOperative_Ruoli] FOREIGN KEY ([IdRuolo]) REFERENCES [organigramma].[Ruoli] ([ID]),
    CONSTRAINT [FK_RuoliUnitaOperative_UnitaOperative] FOREIGN KEY ([IdUnitaOperativa]) REFERENCES [organigramma].[UnitaOperative] ([ID])
);


GO
CREATE UNIQUE CLUSTERED INDEX [IXU_IdRuoloIdUnitaOperativa]
    ON [organigramma].[RuoliUnitaOperative]([IdRuolo] ASC, [IdUnitaOperativa] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IdUnitaOperativa]
    ON [organigramma].[RuoliUnitaOperative]([IdUnitaOperativa] ASC) WITH (FILLFACTOR = 95);

