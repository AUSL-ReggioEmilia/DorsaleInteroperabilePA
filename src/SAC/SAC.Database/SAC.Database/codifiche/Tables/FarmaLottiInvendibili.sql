CREATE TABLE [codifiche].[FarmaLottiInvendibili] (
    [Id]                       UNIQUEIDENTIFIER CONSTRAINT [DF_FarmaLottiInvendibili_Id] DEFAULT (newsequentialid()) NOT NULL,
    [CodiceProdotto]           VARCHAR (16)     NOT NULL,
    [Numero]                   CHAR (1)         NOT NULL,
    [Descrizione]              VARCHAR (256)    NULL,
    [DescrizioneInvendibilita] VARCHAR (256)    NULL,
    [DescrizioneVendibilita]   VARCHAR (480)    NULL,
    [DataVendibilita]          DATE             NULL,
    [DataRicommerciabilita]    DATE             NULL,
    [NonVincolante]            CHAR (1)         NULL,
    [DataInserimento]          DATETIME         CONSTRAINT [DF_FarmaLottiInvendibili_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]             DATETIME         CONSTRAINT [DF_FarmaLottiInvendibili_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento]        VARCHAR (128)    CONSTRAINT [DF_FarmaLottiInvendibili_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]           VARCHAR (128)    CONSTRAINT [DF_FarmaLottiInvendibili_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_FarmaLottiInvendibili] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO
CREATE CLUSTERED INDEX [IX_ProdottoNumero]
    ON [codifiche].[FarmaLottiInvendibili]([CodiceProdotto] ASC, [Numero] ASC);

