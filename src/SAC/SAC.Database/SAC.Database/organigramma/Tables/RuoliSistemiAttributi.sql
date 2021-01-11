CREATE TABLE [organigramma].[RuoliSistemiAttributi] (
    [ID]                UNIQUEIDENTIFIER DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [IdRuoloSistema]    UNIQUEIDENTIFIER NOT NULL,
    [CodiceAttributo]   VARCHAR (64)     NOT NULL,
    [Note]              VARCHAR (128)    NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_RuoliSistemiAttributi_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_RuoliSistemiAttributi_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_RuoliSistemiAttributi_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_RuoliSistemiAttributi_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_RuoliSistemiAttributi] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_RuoliSistemiAttributi_Attributi] FOREIGN KEY ([CodiceAttributo]) REFERENCES [organigramma].[Attributi] ([Codice]),
    CONSTRAINT [FK_RuoliSistemiAttributi_RuoliSistemi] FOREIGN KEY ([IdRuoloSistema]) REFERENCES [organigramma].[RuoliSistemi] ([ID])
);


GO
CREATE UNIQUE CLUSTERED INDEX [IXU_IdSistema_CodiceAttributo]
    ON [organigramma].[RuoliSistemiAttributi]([IdRuoloSistema] ASC, [CodiceAttributo] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_CodiceAttributo]
    ON [organigramma].[RuoliSistemiAttributi]([CodiceAttributo] ASC) WITH (FILLFACTOR = 95);

