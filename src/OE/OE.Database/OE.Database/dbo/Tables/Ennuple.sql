CREATE TABLE [dbo].[Ennuple] (
    [ID]                   UNIQUEIDENTIFIER CONSTRAINT [DF_Ennuple_ID] DEFAULT (newid()) NOT NULL,
    [DataInserimento]      DATETIME2 (0)    CONSTRAINT [DF_Ennuple_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]         DATETIME2 (0)    NOT NULL,
    [UtenteInserimento]    VARCHAR (64)     NOT NULL,
    [UtenteModifica]       VARCHAR (64)     NOT NULL,
    [IDGruppoUtenti]       UNIQUEIDENTIFIER NULL,
    [IDGruppoPrestazioni]  UNIQUEIDENTIFIER NULL,
    [Descrizione]          VARCHAR (256)    NOT NULL,
    [OrarioInizio]         TIME (0)         NULL,
    [OrarioFine]           TIME (0)         NULL,
    [Lunedi]               BIT              CONSTRAINT [DF_Ennuple_Lunedi] DEFAULT ((0)) NOT NULL,
    [Martedi]              BIT              CONSTRAINT [DF_Ennuple_Martedi] DEFAULT ((0)) NOT NULL,
    [Mercoledi]            BIT              CONSTRAINT [DF_Ennuple_Mercoledi] DEFAULT ((0)) NOT NULL,
    [Giovedi]              BIT              CONSTRAINT [DF_Ennuple_Giovedi] DEFAULT ((0)) NOT NULL,
    [Venerdi]              BIT              CONSTRAINT [DF_Ennuple_Venerdi] DEFAULT ((0)) NOT NULL,
    [Sabato]               BIT              CONSTRAINT [DF_Ennuple_Sabato] DEFAULT ((0)) NOT NULL,
    [Domenica]             BIT              CONSTRAINT [DF_Ennuple_Domenica] DEFAULT ((0)) NOT NULL,
    [IDUnitaOperativa]     UNIQUEIDENTIFIER NULL,
    [IDSistemaRichiedente] UNIQUEIDENTIFIER NULL,
    [CodiceRegime]         VARCHAR (16)     NULL,
    [CodicePriorita]       VARCHAR (16)     NULL,
    [Not]                  BIT              CONSTRAINT [DF_Ennuple_Not] DEFAULT ((0)) NOT NULL,
    [IDStato]              TINYINT          CONSTRAINT [DF_Ennuple_IdStato] DEFAULT ((1)) NOT NULL,
    [Note]                 VARCHAR (1024)   NULL,
    CONSTRAINT [PK_Ennuple] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_Ennuple_EnnupleStati] FOREIGN KEY ([IDStato]) REFERENCES [dbo].[EnnupleStati] ([ID]),
    CONSTRAINT [FK_Ennuple_GruppiPrestazioni] FOREIGN KEY ([IDGruppoPrestazioni]) REFERENCES [dbo].[GruppiPrestazioni] ([ID]),
    CONSTRAINT [FK_Ennuple_GruppiUtenti] FOREIGN KEY ([IDGruppoUtenti]) REFERENCES [dbo].[GruppiUtenti] ([ID]),
    CONSTRAINT [FK_Ennuple_Sistemi_IDSistemaRichiedente] FOREIGN KEY ([IDSistemaRichiedente]) REFERENCES [dbo].[Sistemi] ([ID]),
    CONSTRAINT [FK_Ennuple_UnitaOperative] FOREIGN KEY ([IDUnitaOperativa]) REFERENCES [dbo].[UnitaOperative] ([ID])
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_SettaggiUnici]
    ON [dbo].[Ennuple]([IDGruppoUtenti] ASC, [IDGruppoPrestazioni] ASC, [OrarioInizio] ASC, [OrarioFine] ASC, [Lunedi] ASC, [Martedi] ASC, [Mercoledi] ASC, [Giovedi] ASC, [Venerdi] ASC, [Sabato] ASC, [Domenica] ASC, [IDUnitaOperativa] ASC, [IDSistemaRichiedente] ASC, [CodiceRegime] ASC, [CodicePriorita] ASC, [Not] ASC) WITH (FILLFACTOR = 95);

