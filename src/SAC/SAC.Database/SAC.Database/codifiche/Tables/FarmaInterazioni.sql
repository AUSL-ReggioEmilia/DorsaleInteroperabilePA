CREATE TABLE [codifiche].[FarmaInterazioni] (
    [Id]                     UNIQUEIDENTIFIER CONSTRAINT [DF_FarmaInterazioni_Id] DEFAULT (newsequentialid()) NOT NULL,
    [PrincipioAttivo1]       INT              NOT NULL,
    [PrincipioAttivo2]       INT              NOT NULL,
    [DescrizioneInterazione] VARCHAR (256)    NULL,
    [DataInserimento]        DATETIME         CONSTRAINT [DF_FarmaInterazioni_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]           DATETIME         CONSTRAINT [DF_FarmaInterazioni_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento]      VARCHAR (128)    CONSTRAINT [DF_FarmaInterazioni_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]         VARCHAR (128)    CONSTRAINT [DF_FarmaInterazioni_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_FarmaInterazioni] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO
CREATE CLUSTERED INDEX [IX_Codici]
    ON [codifiche].[FarmaInterazioni]([PrincipioAttivo1] ASC, [PrincipioAttivo2] ASC);

