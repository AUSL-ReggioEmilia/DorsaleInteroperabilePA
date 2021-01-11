CREATE TABLE [codifiche].[FarmaGrammature] (
    [Id]                    UNIQUEIDENTIFIER CONSTRAINT [DF_FarmaGrammature_Id] DEFAULT (newsequentialid()) NOT NULL,
    [CodiceProdotto]        VARCHAR (16)     NOT NULL,
    [PrincipioAttivo]       INT              NOT NULL,
    [Unita]                 INT              NULL,
    [QuantitaCapacita]      NUMERIC (14, 4)  NULL,
    [UnitaMisuraCapacita]   VARCHAR (5)      NULL,
    [QuantitaGrammatura]    NUMERIC (14, 4)  NULL,
    [UnitaMisuraGrammatura] VARCHAR (5)      NULL,
    [Percentuale]           NUMERIC (7, 5)   NULL,
    [DataInserimento]       DATETIME         CONSTRAINT [DF_FarmaGrammature_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]          DATETIME         CONSTRAINT [DF_FarmaGrammature_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento]     VARCHAR (128)    CONSTRAINT [DF_FarmaGrammature_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]        VARCHAR (128)    CONSTRAINT [DF_FarmaGrammature_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_FarmaGrammature] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO
CREATE CLUSTERED INDEX [IX_PRODOTTO_PRINCIPIO]
    ON [codifiche].[FarmaGrammature]([CodiceProdotto] ASC, [PrincipioAttivo] ASC);

