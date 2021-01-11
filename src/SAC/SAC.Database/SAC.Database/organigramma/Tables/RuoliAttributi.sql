CREATE TABLE [organigramma].[RuoliAttributi] (
    [ID]                UNIQUEIDENTIFIER DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [IdRuolo]           UNIQUEIDENTIFIER NOT NULL,
    [CodiceAttributo]   VARCHAR (64)     NOT NULL,
    [Note]              VARCHAR (128)    NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_RuoliAttributi_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_RuoliAttributi_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_RuoliAttributi_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_RuoliAttributi_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_RuoliAttributi] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_RuoliAttributi_Attributi] FOREIGN KEY ([CodiceAttributo]) REFERENCES [organigramma].[Attributi] ([Codice]),
    CONSTRAINT [FK_RuoliAttributi_Ruoli] FOREIGN KEY ([IdRuolo]) REFERENCES [organigramma].[Ruoli] ([ID])
);


GO
CREATE UNIQUE CLUSTERED INDEX [IXU_IdRuoloCodiceAttributo]
    ON [organigramma].[RuoliAttributi]([IdRuolo] ASC, [CodiceAttributo] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_CodiceAttributo]
    ON [organigramma].[RuoliAttributi]([CodiceAttributo] ASC) WITH (FILLFACTOR = 95);

