CREATE TABLE [organigramma].[RuoliSistemi] (
    [ID]                UNIQUEIDENTIFIER DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [IdRuolo]           UNIQUEIDENTIFIER NOT NULL,
    [IdSistema]         UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_RuoliSistemi_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_RuoliSistemi_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_RuoliSistemi_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_RuoliSistemi_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_RuoliSistemi] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_RuoliSistemi_Ruoli] FOREIGN KEY ([IdRuolo]) REFERENCES [organigramma].[Ruoli] ([ID]),
    CONSTRAINT [FK_RuoliSistemi_Sistemi] FOREIGN KEY ([IdSistema]) REFERENCES [organigramma].[Sistemi] ([ID])
);


GO
CREATE UNIQUE CLUSTERED INDEX [IXU_IdRuolo_IdSistema]
    ON [organigramma].[RuoliSistemi]([IdRuolo] ASC, [IdSistema] ASC) WITH (FILLFACTOR = 95);

