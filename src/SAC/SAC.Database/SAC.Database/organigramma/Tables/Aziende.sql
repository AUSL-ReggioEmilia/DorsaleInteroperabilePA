CREATE TABLE [organigramma].[Aziende] (
    [Codice]            VARCHAR (16)  NOT NULL,
    [Descrizione]       VARCHAR (128) NULL,
    [DataInserimento]   DATETIME      CONSTRAINT [DF_Aziende_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]      DATETIME      CONSTRAINT [DF_Aziende_DataModifica] DEFAULT (getdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128) CONSTRAINT [DF_Aziende_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128) CONSTRAINT [DF_Aziende_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_Aziende] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);

