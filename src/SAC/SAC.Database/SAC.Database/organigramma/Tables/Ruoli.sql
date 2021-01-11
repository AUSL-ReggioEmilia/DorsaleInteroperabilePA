CREATE TABLE [organigramma].[Ruoli] (
    [ID]                UNIQUEIDENTIFIER DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [Codice]            VARCHAR (16)     NOT NULL,
    [Descrizione]       VARCHAR (128)    NULL,
    [Attivo]            BIT              CONSTRAINT [DF_Ruoli_Attivo] DEFAULT ((1)) NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_Ruoli_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_Ruoli_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_Ruoli_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_Ruoli_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    [Note]              VARCHAR (1024)   NULL,
    CONSTRAINT [PK_Ruoli] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ruoli_Codice]
    ON [organigramma].[Ruoli]([Codice] ASC);

