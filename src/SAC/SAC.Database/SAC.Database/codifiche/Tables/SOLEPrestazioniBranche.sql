CREATE TABLE [codifiche].[SOLEPrestazioniBranche] (
    [PrestazioneId]     UNIQUEIDENTIFIER NOT NULL,
    [BrancaId]          UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_SOLEPrestazioniBranche_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_SOLEPrestazioniBranche_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_SOLEPrestazioniBranche_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_SOLEPrestazioniBranche_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_SOLEPrestazioniBranche] PRIMARY KEY CLUSTERED ([PrestazioneId] ASC, [BrancaId] ASC)
);

