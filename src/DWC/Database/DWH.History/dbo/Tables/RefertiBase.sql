CREATE TABLE [dbo].[RefertiBase] (
    [Id]                       UNIQUEIDENTIFIER NOT NULL,
    [DataPartizione]           SMALLDATETIME    NOT NULL,
    [IdEsterno]                VARCHAR (64)     NOT NULL,
    [IdPaziente]               UNIQUEIDENTIFIER NULL,
    [DataInserimento]          DATETIME         NOT NULL,
    [DataModifica]             DATETIME         NOT NULL,
    [AziendaErogante]          VARCHAR (16)     NOT NULL,
    [SistemaErogante]          VARCHAR (16)     NOT NULL,
    [RepartoErogante]          VARCHAR (64)     NULL,
    [DataReferto]              DATETIME         NOT NULL,
    [NumeroReferto]            VARCHAR (16)     NOT NULL,
    [NumeroNosologico]         VARCHAR (64)     NULL,
    [Cancellato]               BIT              CONSTRAINT [DF_RefertiBase_Cancellato] DEFAULT ((0)) NOT NULL,
    [NumeroPrenotazione]       VARCHAR (32)     NULL,
    [DataModificaEsterno]      DATETIME         NULL,
    [StatoRichiestaCodice]     TINYINT          NOT NULL,
    [RepartoRichiedenteCodice] VARCHAR (16)     NULL,
    [RepartoRichiedenteDescr]  VARCHAR (128)    NULL,
    [IdOrderEntry]             VARCHAR (64)     NULL,
    [DataEvento]               DATETIME         CONSTRAINT [DF_RefertiBase_DataEvento] DEFAULT ('1800-01-01') NOT NULL,
    [Firmato]                  BIT              CONSTRAINT [DF_RefertiBase_Firmato] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RefertiBase] PRIMARY KEY NONCLUSTERED ([Id] ASC, [DataPartizione] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_RefertiBase_DataPartizione] CHECK ([DataPartizione]<CONVERT([smalldatetime],'20070101',(0)))
);








GO
CREATE CLUSTERED INDEX [FK_IdPaziente]
    ON [dbo].[RefertiBase]([IdPaziente] ASC, [DataReferto] ASC, [StatoRichiestaCodice] ASC, [Cancellato] ASC) WITH (FILLFACTOR = 95);


GO



GO
CREATE NONCLUSTERED INDEX [IX_NumeroNosologico]
    ON [dbo].[RefertiBase]([NumeroNosologico] ASC, [StatoRichiestaCodice] ASC, [Cancellato] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_NumeroPrenotazione]
    ON [dbo].[RefertiBase]([NumeroPrenotazione] ASC, [StatoRichiestaCodice] ASC, [Cancellato] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_NumeroReferto]
    ON [dbo].[RefertiBase]([NumeroReferto] ASC, [StatoRichiestaCodice] ASC, [Cancellato] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_DataModifica_Sistema]
    ON [dbo].[RefertiBase]([DataModifica] ASC, [SistemaErogante] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_RepartoRichiedenteCodice]
    ON [dbo].[RefertiBase]([RepartoRichiedenteCodice] ASC, [StatoRichiestaCodice] ASC, [Cancellato] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_SistemaRepartoErogante]
    ON [dbo].[RefertiBase]([SistemaErogante] ASC, [RepartoErogante] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IdOrderEntry]
    ON [dbo].[RefertiBase]([IdOrderEntry] ASC, [StatoRichiestaCodice] ASC, [Cancellato] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_DataReferto]
    ON [dbo].[RefertiBase]([DataReferto] ASC, [StatoRichiestaCodice] ASC, [Cancellato] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IdOrderEntry_DataEvento]
    ON [dbo].[RefertiBase]([IdOrderEntry] ASC, [DataEvento] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_AziendaSistemaErogante_RepartoRichiedente]
    ON [dbo].[RefertiBase]([AziendaErogante] ASC, [SistemaErogante] ASC, [RepartoRichiedenteCodice] ASC) WITH (FILLFACTOR = 40);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_IdEsterno]
    ON [dbo].[RefertiBase]([IdEsterno] ASC)
    INCLUDE([Id], [DataPartizione], [DataModificaEsterno]) WITH (FILLFACTOR = 70);



