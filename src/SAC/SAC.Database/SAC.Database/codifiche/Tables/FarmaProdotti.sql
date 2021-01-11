CREATE TABLE [codifiche].[FarmaProdotti] (
    [Id]                           UNIQUEIDENTIFIER CONSTRAINT [DF_FarmaProdotti1_Id] DEFAULT (newsequentialid()) NOT NULL,
    [CodiceProdotto]               VARCHAR (16)     NULL,
    [CodiceEAN]                    VARCHAR (16)     NULL,
    [CodiceEMEA]                   VARCHAR (20)     NULL,
    [CodiceInternoDitta]           VARCHAR (16)     NULL,
    [Descrizione]                  VARCHAR (256)    NULL,
    [NoPrezzo]                     CHAR (1)         NULL,
    [DataPrezzo1]                  DATE             NULL,
    [TipoPrezzo1]                  CHAR (2)         NULL,
    [Prezzo1Lire]                  INT              NULL,
    [Prezzo1Euro]                  NUMERIC (8, 3)   NULL,
    [DataPrezzo2]                  DATE             NULL,
    [TipoPrezzo2]                  CHAR (2)         NULL,
    [Prezzo2Lire]                  INT              NULL,
    [Prezzo2Euro]                  NUMERIC (8, 3)   NULL,
    [DataPrezzo3]                  DATE             NULL,
    [TipoPrezzo3]                  CHAR (2)         NULL,
    [Prezzo3Lire]                  INT              NULL,
    [Prezzo3Euro]                  NUMERIC (8, 3)   NULL,
    [UnitaDiMisura]                CHAR (2)         NULL,
    [PrezzoUMLire]                 INT              NULL,
    [PrezzoUMEuro]                 NUMERIC (8, 3)   NULL,
    [TariffaDataVigore]            DATE             NULL,
    [TariffaUM]                    VARCHAR (10)     NULL,
    [TariffaLire]                  INT              NULL,
    [TariffaEuro]                  NUMERIC (8, 3)   NULL,
    [DataDalDitta1]                DATE             NULL,
    [Ditta1Produttrice]            VARCHAR (16)     NULL,
    [DivisioneDitta1]              CHAR (2)         NULL,
    [DataDalDitta2]                DATE             NULL,
    [Ditta2Produttrice]            VARCHAR (16)     NULL,
    [DivisioneDitta2]              CHAR (2)         NULL,
    [DataDalAssInde1]              DATE             NULL,
    [AssInde1]                     CHAR (1)         NULL,
    [DataDalAssInde2]              DATE             NULL,
    [AssInde2]                     CHAR (1)         NULL,
    [DittaConcessionaria]          VARCHAR (16)     NULL,
    [DivisioneDittaConcessionaria] CHAR (2)         NULL,
    [ATC]                          VARCHAR (16)     NULL,
    [GruppoTerapeutico]            SMALLINT         NULL,
    [PrincipioAttivo]              INT              NULL,
    [DataPrimaRegistrazione]       DATE             NULL,
    [DataInizioCommercio]          DATE             NULL,
    [Commercio]                    CHAR (1)         NULL,
    [SostituisceIl]                VARCHAR (13)     NULL,
    [SostituitoDa]                 VARCHAR (13)     NULL,
    [ProdottoBaseGenerico]         VARCHAR (13)     NULL,
    [ProdottoDiRiferimento]        VARCHAR (13)     NULL,
    [CodiceNomenclatore]           VARCHAR (9)      NULL,
    [ProntuarioDal]                DATE             NULL,
    [ProntuarioAl]                 DATE             NULL,
    [DataDalSSNClasse1]            DATE             NULL,
    [RegimeSSN1]                   CHAR (2)         NULL,
    [Classe1]                      CHAR (2)         NULL,
    [DataDalSSNClasse2]            DATE             NULL,
    [RegimeSSN2]                   CHAR (2)         NULL,
    [Classe2]                      CHAR (2)         NULL,
    [DataDalPrescrivibilita1]      DATE             NULL,
    [Prescrivibilita1]             CHAR (2)         NULL,
    [DataDalPrescrivibilita2]      DATE             NULL,
    [Prescrivibilita2]             CHAR (2)         NULL,
    [DataDalTipoRicetta1]          DATE             NULL,
    [TipoRicetta1]                 CHAR (2)         NULL,
    [DataDalTipoRicetta2]          DATE             NULL,
    [TipoRicetta2]                 CHAR (2)         NULL,
    [DataDalNotePrescrizione1]     DATE             NULL,
    [NoteSullaPrescrizione1]       CHAR (3)         NULL,
    [DataDalNotePrescrizione2]     DATE             NULL,
    [NoteSullaPrescrizione2]       CHAR (3)         NULL,
    [TipoProdotto]                 CHAR (2)         NULL,
    [Caratteristica]               CHAR (2)         NULL,
    [Obbligatorieta]               CHAR (2)         NULL,
    [Forma]                        CHAR (2)         NULL,
    [Contenitore]                  CHAR (2)         NULL,
    [Stupefacente]                 CHAR (2)         NULL,
    [CodiceIVA]                    TINYINT          NULL,
    [Temperatura]                  CHAR (2)         NULL,
    [Validita]                     CHAR (2)         NULL,
    [CodiceDegrassi]               CHAR (4)         NULL,
    [Particolare]                  CHAR (2)         NULL,
    [VendibilitaAl]                CHAR (19)        NULL,
    [Ricommerciabilita]            VARCHAR (19)     NULL,
    [RitiroDefinitivo]             VARCHAR (19)     NULL,
    [DataInizioEsaurimento]        DATE             NULL,
    [OperazioneTecnica]            CHAR (1)         NULL,
    [DegrassiBDF400]               CHAR (4)         NULL,
    [DataPrezzoRimborso]           DATE             NULL,
    [PrezzoMaxRimborsoLire]        INT              NULL,
    [PrezzoMaxRimborsoEuro]        NUMERIC (8, 3)   NULL,
    [DataInserimento]              DATETIME         CONSTRAINT [DF_FarmaProdotti1_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]                 DATETIME         CONSTRAINT [DF_FarmaProdotti1_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento]            VARCHAR (128)    CONSTRAINT [DF_FarmaProdotti1_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]               VARCHAR (128)    CONSTRAINT [DF_FarmaProdotti1_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_FarmaProdotti] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CODICEPRODOTTO]
    ON [codifiche].[FarmaProdotti]([CodiceProdotto] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_EAN]
    ON [codifiche].[FarmaProdotti]([CodiceEAN] ASC) WHERE ([CODICEEAN] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_EMEA]
    ON [codifiche].[FarmaProdotti]([CodiceEMEA] ASC) WHERE ([CODICEEMEA] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_PrincipioAttivo]
    ON [codifiche].[FarmaProdotti]([PrincipioAttivo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DESCRIZIONE]
    ON [codifiche].[FarmaProdotti]([Descrizione] ASC);

