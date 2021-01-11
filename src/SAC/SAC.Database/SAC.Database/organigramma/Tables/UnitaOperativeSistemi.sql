CREATE TABLE [organigramma].[UnitaOperativeSistemi] (
    [ID]                UNIQUEIDENTIFIER DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [IdUnitaOperativa]  UNIQUEIDENTIFIER NOT NULL,
    [IdSistema]         UNIQUEIDENTIFIER NOT NULL,
    [Codice]            VARCHAR (16)     NOT NULL,
    [CodiceAzienda]     VARCHAR (16)     NOT NULL,
    [Descrizione]       VARCHAR (128)    NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_UnitaOperativeSistemi_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_UnitaOperativeSistemi_DataModifica] DEFAULT (getdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_UnitaOperativeSistemi_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_UnitaOperativeSistemi_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_UnitaOperativeSistemi] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_UnitaOperativeSistemi_Aziende] FOREIGN KEY ([CodiceAzienda]) REFERENCES [organigramma].[Aziende] ([Codice]),
    CONSTRAINT [FK_UnitaOperativeSistemi_Sistemi] FOREIGN KEY ([IdSistema]) REFERENCES [organigramma].[Sistemi] ([ID]),
    CONSTRAINT [FK_UnitaOperativeSistemi_UnitaOperative] FOREIGN KEY ([IdUnitaOperativa]) REFERENCES [organigramma].[UnitaOperative] ([ID])
);


GO
CREATE UNIQUE CLUSTERED INDEX [IXU_UnitaOperativaSistema]
    ON [organigramma].[UnitaOperativeSistemi]([IdUnitaOperativa] ASC, [IdSistema] ASC) WITH (FILLFACTOR = 95);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_SistemaCodiceCodifica]
    ON [organigramma].[UnitaOperativeSistemi]([IdSistema] ASC, [Codice] ASC, [CodiceAzienda] ASC) WITH (FILLFACTOR = 95);

