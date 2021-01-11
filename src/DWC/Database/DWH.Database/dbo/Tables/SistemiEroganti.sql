CREATE TABLE [dbo].[SistemiEroganti] (
    [Id]                            UNIQUEIDENTIFIER CONSTRAINT [DF_SistemiEroganti_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [AziendaErogante]               VARCHAR (16)     NOT NULL,
    [SistemaErogante]               VARCHAR (16)     NOT NULL,
    [Descrizione]                   VARCHAR (128)    NULL,
    [RuoloVisualizzazione]          VARCHAR (128)    NULL,
    [EmailControlloQualitaPassivo]  VARCHAR (128)    NULL,
    [TipoReferti]                   BIT              CONSTRAINT [DF_SistemiEroganti_TipoReferti] DEFAULT ((0)) NOT NULL,
    [TipoRicoveri]                  BIT              CONSTRAINT [DF_SistemiEroganti_TipoRicoveri] DEFAULT ((0)) NOT NULL,
    [LoginToSac]                    VARCHAR (64)     NULL,
    [RuoloManager]                  VARCHAR (128)    NULL,
    [GeneraAnteprimaReferto]        BIT              CONSTRAINT [DF_SistemiEroganti_GeneraAnteprimaReferto] DEFAULT ((0)) NOT NULL,
    [TipoNoteAnamnestiche]          BIT              CONSTRAINT [DF_SistemiEroganti_TipoNoteAnamnestiche] DEFAULT ((0)) NOT NULL,
    [PrioritaInvioReferti]          SMALLINT         CONSTRAINT [DF_SistemiEroganti_PrioritaInvioReferti] DEFAULT ((5)) NOT NULL,
    [PrioritaInvioEventi]           SMALLINT         CONSTRAINT [DF_SistemiEroganti_PrioritaInvioEventi] DEFAULT ((5)) NOT NULL,
    [PrioritaInvioNoteAnamnestiche] SMALLINT         CONSTRAINT [DF_SistemiEroganti_PrioritaInvioNoteAnamnestiche] DEFAULT ((5)) NOT NULL,
    [RefertiFirmati]                BIT              CONSTRAINT [DF_SistemiEroganti_RefertiFirmati] DEFAULT ((0)) NOT NULL,
    [MassimaleDiScartoMesi]         INT              NULL,
    CONSTRAINT [PK_SistemiEroganti] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);








GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AziendaEroganteSistemiEroganti]
    ON [dbo].[SistemiEroganti]([AziendaErogante] ASC, [SistemaErogante] ASC) WITH (FILLFACTOR = 95);

