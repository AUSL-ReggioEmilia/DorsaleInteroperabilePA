CREATE TABLE [dbo].[EnnupleArchiviazione] (
    [Id]                                UNIQUEIDENTIFIER CONSTRAINT [DF_EnnupleArchiviazione_ID] DEFAULT (newsequentialid()) NOT NULL,
    [Disabilitato]                      BIT              CONSTRAINT [DF_EnnupleArchiviazione_Disabilitato] DEFAULT ((0)) NOT NULL,
    [DataInserimento]                   DATETIME2 (7)    CONSTRAINT [DF_EnnupleArchiviazione_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]                      DATETIME2 (7)    CONSTRAINT [DF_EnnupleArchiviazione_DataModifica] DEFAULT (getdate()) NOT NULL,
    [UtenteInserimento]                 VARCHAR (64)     CONSTRAINT [DF_EnnupleArchiviazione_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]                    VARCHAR (64)     CONSTRAINT [DF_EnnupleArchiviazione_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    [Descrizione]                       VARCHAR (128)    NULL,
    [IdSistemaRichiedente]              UNIQUEIDENTIFIER NULL,
    [IdUnitaOperativa]                  UNIQUEIDENTIFIER NULL,
    [IdSistemaErogante]                 UNIQUEIDENTIFIER NULL,
    [GiorniOrdiniCompletati]            INT              CONSTRAINT [DF_EnnupleArchiviazione_GiorniOrdiniCompletati] DEFAULT ((30)) NOT NULL,
    [GiorniOrdiniNoRisposta]            INT              CONSTRAINT [DF_EnnupleArchiviazione_GiorniOrdiniNoRisposta] DEFAULT ((120)) NOT NULL,
    [GiorniOrdiniPrenotazioniPassate]   INT              CONSTRAINT [DF_EnnupleArchiviazione_GiorniOrdiniPrenotazioniPassate] DEFAULT ((120)) NOT NULL,
    [GiorniOrdiniAltro]                 INT              CONSTRAINT [DF_EnnupleArchiviazione_GiorniOrdiniAltro] DEFAULT ((180)) NOT NULL,
    [GiorniVersioniCompletati]          INT              CONSTRAINT [DF_EnnupleArchiviazione_GiorniVersioniCompletati] DEFAULT ((1)) NOT NULL,
    [GiorniVersioniPrenotazioniPassate] INT              CONSTRAINT [DF_EnnupleArchiviazione_GiorniVersioniPrenotazioniPassate] DEFAULT ((7)) NOT NULL,
    CONSTRAINT [PK_EnnupleArchiviazione] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_IDSistemaErogante_Sistemi] FOREIGN KEY ([IdSistemaErogante]) REFERENCES [dbo].[Sistemi] ([ID]),
    CONSTRAINT [FK_IDSistemaRichiedente_Sistemi] FOREIGN KEY ([IdSistemaRichiedente]) REFERENCES [dbo].[Sistemi] ([ID]),
    CONSTRAINT [FK_IDUnitaOperativa_UnitaOperative] FOREIGN KEY ([IdUnitaOperativa]) REFERENCES [dbo].[UnitaOperative] ([ID])
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_Ennupla]
    ON [dbo].[EnnupleArchiviazione]([IdSistemaRichiedente] ASC, [IdUnitaOperativa] ASC, [IdSistemaErogante] ASC);

