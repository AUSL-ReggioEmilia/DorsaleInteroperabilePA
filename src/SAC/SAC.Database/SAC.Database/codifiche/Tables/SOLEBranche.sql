CREATE TABLE [codifiche].[SOLEBranche] (
    [Id]                UNIQUEIDENTIFIER CONSTRAINT [DF_SOLEBranche_Id] DEFAULT (newsequentialid()) NOT NULL,
    [CodiceBranca]      VARCHAR (16)     NOT NULL,
    [DescrizioneBranca] VARCHAR (256)    NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_BrancheSOLE_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_BrancheSOLE_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_BrancheSOLE_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_BrancheSOLE_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_SOLEBranche] PRIMARY KEY CLUSTERED ([Id] ASC)
);

