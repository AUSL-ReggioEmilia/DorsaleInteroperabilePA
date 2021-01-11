CREATE TABLE [organigramma].[OggettiActiveDirectoryUtentiAccessiCalcolati] (
    [Id]                UNIQUEIDENTIFIER CONSTRAINT [DF_OggettiActiveDirectoryUtentiAccessiCalcolati_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [IdUtente]          UNIQUEIDENTIFIER NOT NULL,
    [Accesso]           VARCHAR (256)    NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_OggettiActiveDirectoryUtentiAccessiCalcolati_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_OggettiActiveDirectoryUtentiAccessiCalcolati_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_OggettiActiveDirectoryUtentiAccessiCalcolati_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_OggettiActiveDirectoryUtentiAccessiCalcolati_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_OggettiActiveDirectoryUtentiAccessiCalcolati] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_OggettiActiveDirectoryUtentiAccessiCalcolati_OggettiActiveDirectory_Utente] FOREIGN KEY ([IdUtente]) REFERENCES [organigramma].[OggettiActiveDirectory] ([Id])
);


GO
CREATE UNIQUE CLUSTERED INDEX [IXU_Utente_Accesso]
    ON [organigramma].[OggettiActiveDirectoryUtentiAccessiCalcolati]([IdUtente] ASC, [Accesso] ASC) WITH (FILLFACTOR = 60);

