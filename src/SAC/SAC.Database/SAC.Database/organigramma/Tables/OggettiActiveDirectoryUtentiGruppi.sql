CREATE TABLE [organigramma].[OggettiActiveDirectoryUtentiGruppi] (
    [Id]                UNIQUEIDENTIFIER CONSTRAINT [DF_OggettiActiveDirectoryUtentiGruppi_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [IdUtente]          UNIQUEIDENTIFIER NOT NULL,
    [IdGruppo]          UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_OggettiActiveDirectoryUtentiGruppi_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_OggettiActiveDirectoryUtentiGruppi_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_OggettiActiveDirectoryUtentiGruppi_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_OggettiActiveDirectoryUtentiGruppi_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_OggettiActiveDirectoryUtentiGruppi] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_OggettiActiveDirectoryUtentiGruppi_OggettiActiveDirectory_Gruppo] FOREIGN KEY ([IdGruppo]) REFERENCES [organigramma].[OggettiActiveDirectory] ([Id]),
    CONSTRAINT [FK_OggettiActiveDirectoryUtentiGruppi_OggettiActiveDirectory_Utente] FOREIGN KEY ([IdUtente]) REFERENCES [organigramma].[OggettiActiveDirectory] ([Id])
);


GO
CREATE UNIQUE CLUSTERED INDEX [IXU_Utenti_Gruppi]
    ON [organigramma].[OggettiActiveDirectoryUtentiGruppi]([IdUtente] ASC, [IdGruppo] ASC) WITH (FILLFACTOR = 60);


GO
CREATE NONCLUSTERED INDEX [IX_IdGruppi]
    ON [organigramma].[OggettiActiveDirectoryUtentiGruppi]([IdGruppo] ASC)
    INCLUDE([IdUtente]);


GO
GRANT DELETE
    ON OBJECT::[organigramma].[OggettiActiveDirectoryUtentiGruppi] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[organigramma].[OggettiActiveDirectoryUtentiGruppi] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[organigramma].[OggettiActiveDirectoryUtentiGruppi] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[organigramma].[OggettiActiveDirectoryUtentiGruppi] TO [DataAccessSISS]
    AS [dbo];

