CREATE TABLE [dbo].[EventiBase] (
    [Id]                  UNIQUEIDENTIFIER NOT NULL,
    [IdEsterno]           VARCHAR (64)     NOT NULL,
    [DataModificaEsterno] DATETIME         NULL,
    [IdPaziente]          UNIQUEIDENTIFIER NULL,
    [DataInserimento]     DATETIME         NOT NULL,
    [DataModifica]        DATETIME         NOT NULL,
    [AziendaErogante]     VARCHAR (16)     NOT NULL,
    [SistemaErogante]     VARCHAR (16)     NOT NULL,
    [RepartoErogante]     VARCHAR (64)     NULL,
    [DataEvento]          DATETIME         NOT NULL,
    [StatoCodice]         INT              CONSTRAINT [DF_EventiBase_StatoCodice] DEFAULT ((0)) NOT NULL,
    [TipoEventoCodice]    VARCHAR (16)     NOT NULL,
    [TipoEventoDescr]     VARCHAR (64)     NOT NULL,
    [NumeroNosologico]    VARCHAR (64)     NOT NULL,
    [TipoEpisodio]        VARCHAR (16)     NULL,
    [RepartoCodice]       VARCHAR (16)     NULL,
    [RepartoDescr]        VARCHAR (128)    NULL,
    [Diagnosi]            VARCHAR (1024)   NULL,
    [DataPartizione]      SMALLDATETIME    NOT NULL,
    CONSTRAINT [PK_EventiBase] PRIMARY KEY NONCLUSTERED ([Id] ASC, [DataPartizione] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_EventiBase_DataPartizione] CHECK ([DataPartizione]>=CONVERT([datetime],'20070101',(0)))
);










GO
CREATE CLUSTERED INDEX [IX_EventiBase_Nosologico]
    ON [dbo].[EventiBase]([NumeroNosologico] ASC, [AziendaErogante] ASC, [TipoEventoCodice] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_Azienda_Sistema_RepartoRicovero]
    ON [dbo].[EventiBase]([AziendaErogante] ASC, [SistemaErogante] ASC, [RepartoCodice] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_DataEvento]
    ON [dbo].[EventiBase]([DataEvento] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_EventiBase_DataModifica_Sistema]
    ON [dbo].[EventiBase]([DataModifica] ASC, [SistemaErogante] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_EventiBase_IdPaziente_Azienda_Sistema_Nosologico]
    ON [dbo].[EventiBase]([IdPaziente] ASC, [AziendaErogante] ASC, [SistemaErogante] ASC, [NumeroNosologico] ASC) WITH (FILLFACTOR = 95);


GO



GO
CREATE NONCLUSTERED INDEX [IX_RepartoRicoveroCodice]
    ON [dbo].[EventiBase]([RepartoCodice] ASC) WITH (FILLFACTOR = 95);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_IdEsterno]
    ON [dbo].[EventiBase]([IdEsterno] ASC)
    INCLUDE([Id], [DataPartizione], [DataModificaEsterno]) WITH (FILLFACTOR = 70);



