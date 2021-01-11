CREATE TABLE [dbo].[Oscuramenti] (
    [Id]                       UNIQUEIDENTIFIER CONSTRAINT [DF_Oscuramenti_Id] DEFAULT (newsequentialid()) NOT NULL,
    [AziendaErogante]          VARCHAR (16)     NULL,
    [SistemaErogante]          VARCHAR (16)     NULL,
    [NumeroNosologico]         VARCHAR (64)     NULL,
    [RepartoRichiedenteCodice] VARCHAR (16)     NULL,
    [NumeroPrenotazione]       VARCHAR (32)     NULL,
    [NumeroReferto]            VARCHAR (16)     NULL,
    [IdOrderEntry]             VARCHAR (64)     NULL,
    [Note]                     VARCHAR (1024)   NULL,
    [DataInserimento]          DATETIME         CONSTRAINT [DF_Oscuramenti_DataInserimento] DEFAULT (sysutcdatetime()) NOT NULL,
    [DataModifica]             DATETIME         CONSTRAINT [DF_Oscuramenti_DataModifica] DEFAULT (sysutcdatetime()) NOT NULL,
    [UtenteInserimento]        VARCHAR (128)    CONSTRAINT [DF_Oscuramenti_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]           VARCHAR (128)    CONSTRAINT [DF_Oscuramenti_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    [CodiceOscuramento]        INT              IDENTITY (1, 1) NOT NULL,
    [RepartoErogante]          VARCHAR (64)     NULL,
    [StrutturaEroganteCodice]  VARCHAR (64)     NULL,
    [TipoOscuramento]          TINYINT          NULL,
    [Titolo]                   VARCHAR (50)     NULL,
    [Parola]                   VARCHAR (64)     NULL,
    [IdEsternoReferto]         VARCHAR (64)     NULL,
    [ApplicaDWH]               BIT              CONSTRAINT [DF_Oscuramenti_ApplicaDWH] DEFAULT ((1)) NOT NULL,
    [ApplicaSole]              BIT              CONSTRAINT [DF_Oscuramenti_ApplicaSole] DEFAULT ((1)) NOT NULL,
    [Stato]                    VARCHAR (16)     CONSTRAINT [DF_Oscuramenti_Stato] DEFAULT ('Completato') NOT NULL,
    [IdCorrelazione]           UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Oscuramenti] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [CK_Oscuramenti_Stato] CHECK ([Stato]='Inserito' OR [Stato]='Completato')
);










GO
CREATE UNIQUE CLUSTERED INDEX [IXC_Tipo_Codice]
    ON [dbo].[Oscuramenti]([TipoOscuramento] ASC, [CodiceOscuramento] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RepartoRichiedente]
    ON [dbo].[Oscuramenti]([RepartoRichiedenteCodice] ASC, [SistemaErogante] ASC, [AziendaErogante] ASC) WHERE ([RepartoRichiedenteCodice] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_NumeroNosologico]
    ON [dbo].[Oscuramenti]([NumeroNosologico] ASC, [AziendaErogante] ASC) WHERE ([NumeroNosologico] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_IDOrderEntry]
    ON [dbo].[Oscuramenti]([IdOrderEntry] ASC, [SistemaErogante] ASC, [AziendaErogante] ASC) WHERE ([IdOrderEntry] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_NumeroPrenotazione]
    ON [dbo].[Oscuramenti]([NumeroPrenotazione] ASC, [SistemaErogante] ASC, [AziendaErogante] ASC) WHERE ([NumeroPrenotazione] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_Referto]
    ON [dbo].[Oscuramenti]([NumeroReferto] ASC, [SistemaErogante] ASC, [AziendaErogante] ASC) WHERE ([NumeroReferto] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_Eroganti]
    ON [dbo].[Oscuramenti]([AziendaErogante] ASC, [SistemaErogante] ASC, [RepartoErogante] ASC, [StrutturaEroganteCodice] ASC) WHERE ([AZIENDAEROGANTE] IS NOT NULL AND [SISTEMAEROGANTE] IS NOT NULL AND [REPARTOEROGANTE] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_IdEsternoReferto]
    ON [dbo].[Oscuramenti]([IdEsternoReferto] ASC) WHERE ([IdEsternoReferto] IS NOT NULL);

