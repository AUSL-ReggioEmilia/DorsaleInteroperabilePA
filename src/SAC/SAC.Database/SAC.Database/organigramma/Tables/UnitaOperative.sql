CREATE TABLE [organigramma].[UnitaOperative] (
    [ID]                UNIQUEIDENTIFIER CONSTRAINT [DF_UnitaOperative_ID] DEFAULT (newid()) NOT NULL,
    [Codice]            VARCHAR (16)     NOT NULL,
    [Descrizione]       VARCHAR (128)    NULL,
    [CodiceAzienda]     VARCHAR (16)     NOT NULL,
    [Attivo]            BIT              CONSTRAINT [DF_UnitaOperative_Attivo] DEFAULT ((1)) NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_UnitaOperative_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_UnitaOperative_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_UnitaOperative_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_UnitaOperative_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_UnitaOperative] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_UnitaOperative_Aziende] FOREIGN KEY ([CodiceAzienda]) REFERENCES [organigramma].[Aziende] ([Codice])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_UnitaOperative_UOAzienda]
    ON [organigramma].[UnitaOperative]([Codice] ASC, [CodiceAzienda] ASC) WITH (FILLFACTOR = 95);

