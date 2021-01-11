CREATE TABLE [codifiche].[FarmaArchivioAtcGmp] (
    [Id]                UNIQUEIDENTIFIER CONSTRAINT [DF_FarmaArchivioAtcGmp_Id] DEFAULT (newsequentialid()) NOT NULL,
    [Codice]            VARCHAR (16)     NOT NULL,
    [Descrizione]       VARCHAR (256)    NULL,
    [Intermedio]        CHAR (1)         NULL,
    [Genere]            CHAR (1)         NULL,
    [ElementoAttivo]    CHAR (1)         NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_FarmaArchivioAtcGmp_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_FarmaArchivioAtcGmp_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_FarmaArchivioAtcGmp_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_FarmaArchivioAtcGmp_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_ArchivioAtcGmp] PRIMARY KEY CLUSTERED ([Id] ASC)
);

