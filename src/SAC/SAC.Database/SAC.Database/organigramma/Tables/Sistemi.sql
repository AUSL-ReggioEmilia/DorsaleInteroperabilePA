CREATE TABLE [organigramma].[Sistemi] (
    [ID]                UNIQUEIDENTIFIER CONSTRAINT [DF_Sistemi_ID] DEFAULT (newid()) NOT NULL,
    [Codice]            VARCHAR (16)     NOT NULL,
    [CodiceAzienda]     VARCHAR (16)     NOT NULL,
    [Descrizione]       VARCHAR (128)    NULL,
    [Erogante]          BIT              CONSTRAINT [DF_Sistemi_Erogante] DEFAULT ((0)) NOT NULL,
    [Richiedente]       BIT              CONSTRAINT [DF_Sistemi_Richiedente] DEFAULT ((0)) NOT NULL,
    [Attivo]            BIT              CONSTRAINT [DF_Sistemi_Attivo] DEFAULT ((1)) NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_Sistemi_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_Sistemi_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_Sistemi_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_Sistemi_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_Sistemi] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [CK_Sistemi_RichiedenteErogante] CHECK NOT FOR REPLICATION (NOT ([Erogante]=(0) AND [Richiedente]=(0))),
    CONSTRAINT [FK_Sistemi_Aziende] FOREIGN KEY ([CodiceAzienda]) REFERENCES [organigramma].[Aziende] ([Codice])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Sistemi_SistemaAzienda]
    ON [organigramma].[Sistemi]([Codice] ASC, [CodiceAzienda] ASC) WITH (FILLFACTOR = 95);

