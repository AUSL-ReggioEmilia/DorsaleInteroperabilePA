CREATE TABLE [organigramma].[OggettiActiveDirectory] (
    [Id]                  UNIQUEIDENTIFIER NOT NULL,
    [Utente]              VARCHAR (128)    NOT NULL,
    [Tipo]                VARCHAR (32)     NOT NULL,
    [Descrizione]         VARCHAR (256)    NULL,
    [Cognome]             VARCHAR (64)     NULL,
    [Nome]                VARCHAR (64)     NULL,
    [CodiceFiscale]       VARCHAR (16)     NULL,
    [Matricola]           VARCHAR (64)     NULL,
    [Email]               VARCHAR (256)    NULL,
    [Attivo]              BIT              CONSTRAINT [DF_Utenti_Attivo] DEFAULT ((1)) NOT NULL,
    [DataInserimento]     DATETIME         CONSTRAINT [DF_OggettiActiveDirectory_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]        DATETIME         CONSTRAINT [DF_OggettiActiveDirectory_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento]   VARCHAR (128)    CONSTRAINT [DF_OggettiActiveDirectory_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]      VARCHAR (128)    CONSTRAINT [DF_OggettiActiveDirectory_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    [DataModificaEsterna] DATETIME         CONSTRAINT [DF_OggettiActiveDirectory_DataModificaEsterna] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_Utenti] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [CK_OggettiActiveDirectory_Tipo] CHECK ([Tipo]='Gruppo' OR [Tipo]='Utente')
);


GO
CREATE CLUSTERED INDEX [IXC_DataInserimento]
    ON [organigramma].[OggettiActiveDirectory]([DataInserimento] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_Utenti_AccountName]
    ON [organigramma].[OggettiActiveDirectory]([Utente] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Tipo]
    ON [organigramma].[OggettiActiveDirectory]([Tipo] ASC, [Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Attivo]
    ON [organigramma].[OggettiActiveDirectory]([Attivo] ASC, [Tipo] ASC, [Id] ASC);


GO
GRANT DELETE
    ON OBJECT::[organigramma].[OggettiActiveDirectory] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[organigramma].[OggettiActiveDirectory] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[organigramma].[OggettiActiveDirectory] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[organigramma].[OggettiActiveDirectory] TO [DataAccessSISS]
    AS [dbo];

