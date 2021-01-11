CREATE TABLE [codifiche].[FarmaMonografieSezioni] (
    [Id]                      UNIQUEIDENTIFIER CONSTRAINT [DF_FarmaMonografieSezioni_Id] DEFAULT (newsequentialid()) NOT NULL,
    [CodiceSezione]           VARCHAR (16)     NOT NULL,
    [DescrizioneDellaSezione] VARCHAR (35)     NULL,
    [DataInserimento]         DATETIME         CONSTRAINT [DF_FarmaMonografieSezioni_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]            DATETIME         CONSTRAINT [DF_FarmaMonografieSezioni_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento]       VARCHAR (128)    CONSTRAINT [DF_FarmaMonografieSezioni_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]          VARCHAR (128)    CONSTRAINT [DF_FarmaMonografieSezioni_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_FarmaMonografieSezioni] PRIMARY KEY CLUSTERED ([Id] ASC)
);

