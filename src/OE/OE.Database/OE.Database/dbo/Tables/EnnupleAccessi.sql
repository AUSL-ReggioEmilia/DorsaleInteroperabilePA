CREATE TABLE [dbo].[EnnupleAccessi] (
    [ID]                UNIQUEIDENTIFIER CONSTRAINT [DF_EnnupleAccessi_ID] DEFAULT (newid()) NOT NULL,
    [DataInserimento]   DATETIME2 (0)    CONSTRAINT [DF_EnnupleAccessi_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]      DATETIME2 (0)    NOT NULL,
    [UtenteInserimento] VARCHAR (64)     NOT NULL,
    [UtenteModifica]    VARCHAR (64)     NOT NULL,
    [IDGruppoUtenti]    UNIQUEIDENTIFIER NULL,
    [Descrizione]       VARCHAR (256)    NOT NULL,
    [IDSistemaErogante] UNIQUEIDENTIFIER NULL,
    [R]                 BIT              CONSTRAINT [DF_EnnupleAccessi_R] DEFAULT ((0)) NOT NULL,
    [I]                 BIT              CONSTRAINT [DF_EnnupleAccessi_I] DEFAULT ((0)) NOT NULL,
    [S]                 BIT              CONSTRAINT [DF_EnnupleAccessi_S] DEFAULT ((0)) NOT NULL,
    [Not]               BIT              CONSTRAINT [DF_EnnupleAccessi_Not] DEFAULT ((0)) NOT NULL,
    [IDStato]           TINYINT          CONSTRAINT [DF_EnnupleAccessi_IDStato] DEFAULT ((1)) NOT NULL,
    [Note]              VARCHAR (1024)   NULL,
    CONSTRAINT [PK_EnnupleAccessi] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_EnnupleAccessi_EnnupleStati] FOREIGN KEY ([IDStato]) REFERENCES [dbo].[EnnupleStati] ([ID]),
    CONSTRAINT [FK_EnnupleAccessi_GruppiUtenti] FOREIGN KEY ([IDGruppoUtenti]) REFERENCES [dbo].[GruppiUtenti] ([ID]),
    CONSTRAINT [FK_EnnupleAccessi_Sistemi_IDSistemaErogante] FOREIGN KEY ([IDSistemaErogante]) REFERENCES [dbo].[Sistemi] ([ID])
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_GruppoSistemaNot]
    ON [dbo].[EnnupleAccessi]([IDGruppoUtenti] ASC, [IDSistemaErogante] ASC, [Not] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lettura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EnnupleAccessi', @level2type = N'COLUMN', @level2name = N'R';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Inserimento/Modifica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EnnupleAccessi', @level2type = N'COLUMN', @level2name = N'I';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Inoltro/Cancellazione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EnnupleAccessi', @level2type = N'COLUMN', @level2name = N'S';

