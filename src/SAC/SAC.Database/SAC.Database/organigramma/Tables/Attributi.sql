CREATE TABLE [organigramma].[Attributi] (
    [Codice]                VARCHAR (64)  NOT NULL,
    [Descrizione]           VARCHAR (256) NULL,
    [UsoPerRuolo]           BIT           DEFAULT ((1)) NOT NULL,
    [UsoPerUnitaOperativa]  BIT           DEFAULT ((1)) NOT NULL,
    [UsoPerSistemaErogante] BIT           DEFAULT ((1)) NOT NULL,
    [DataInserimento]       DATETIME      CONSTRAINT [DF_Attributi_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]          DATETIME      CONSTRAINT [DF_Attributi_DataModifica] DEFAULT (getdate()) NOT NULL,
    [UtenteInserimento]     VARCHAR (128) CONSTRAINT [DF_Attributi_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]        VARCHAR (128) CONSTRAINT [DF_Attributi_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_Attributi] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);

