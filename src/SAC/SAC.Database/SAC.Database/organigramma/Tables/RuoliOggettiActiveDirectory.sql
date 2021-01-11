CREATE TABLE [organigramma].[RuoliOggettiActiveDirectory] (
    [ID]                UNIQUEIDENTIFIER DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [IdRuolo]           UNIQUEIDENTIFIER NOT NULL,
    [IdUtente]          UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_RuoliOggettiActiveDirectory_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_RuoliOggettiActiveDirectory_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_RuoliOggettiActiveDirectory_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_RuoliOggettiActiveDirectory_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_RuoliOggettiActiveDirectory] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_RuoliOggettiActiveDirectory_OggettiActiveDirectory] FOREIGN KEY ([IdUtente]) REFERENCES [organigramma].[OggettiActiveDirectory] ([Id]),
    CONSTRAINT [FK_RuoliOggettiActiveDirectory_Ruoli] FOREIGN KEY ([IdRuolo]) REFERENCES [organigramma].[Ruoli] ([ID])
);




GO
CREATE UNIQUE CLUSTERED INDEX [IXU_IdRuoloUtente]
    ON [organigramma].[RuoliOggettiActiveDirectory]([IdRuolo] ASC, [IdUtente] ASC) WITH (FILLFACTOR = 95);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_IdUtenteIdRuolo]
    ON [organigramma].[RuoliOggettiActiveDirectory]([IdUtente] ASC, [IdRuolo] ASC);

