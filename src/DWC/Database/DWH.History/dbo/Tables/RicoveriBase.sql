CREATE TABLE [dbo].[RicoveriBase] (
    [Id]                        UNIQUEIDENTIFIER NOT NULL,
    [IdEsterno]                 VARCHAR (64)     NOT NULL,
    [DataModificaEsterno]       DATETIME         NULL,
    [DataInserimento]           DATETIME         NOT NULL,
    [DataModifica]              DATETIME         NOT NULL,
    [StatoCodice]               TINYINT          CONSTRAINT [DF_RicoveriBase_StatoCodice] DEFAULT ((0)) NOT NULL,
    [Cancellato]                BIT              CONSTRAINT [DF_RicoveriBase_Cancellato] DEFAULT ((0)) NOT NULL,
    [NumeroNosologico]          VARCHAR (64)     NOT NULL,
    [AziendaErogante]           VARCHAR (16)     NOT NULL,
    [SistemaErogante]           VARCHAR (16)     NOT NULL,
    [RepartoErogante]           VARCHAR (64)     NULL,
    [IdPaziente]                UNIQUEIDENTIFIER NULL,
    [OspedaleCodice]            VARCHAR (16)     NULL,
    [OspedaleDescr]             VARCHAR (128)    NULL,
    [TipoRicoveroCodice]        VARCHAR (16)     NULL,
    [TipoRicoveroDescr]         VARCHAR (128)    NULL,
    [Diagnosi]                  VARCHAR (1024)   NULL,
    [DataAccettazione]          DATETIME         NULL,
    [RepartoAccettazioneCodice] VARCHAR (16)     NULL,
    [RepartoAccettazioneDescr]  VARCHAR (128)    NULL,
    [DataTrasferimento]         DATETIME         NULL,
    [RepartoCodice]             VARCHAR (16)     NULL,
    [RepartoDescr]              VARCHAR (128)    NULL,
    [SettoreCodice]             VARCHAR (16)     NULL,
    [SettoreDescr]              VARCHAR (128)    NULL,
    [LettoCodice]               VARCHAR (16)     NULL,
    [DataDimissione]            DATETIME         NULL,
    [DataPartizione]            SMALLDATETIME    NOT NULL,
    CONSTRAINT [PK_RicoveriBase] PRIMARY KEY CLUSTERED ([DataPartizione] ASC, [Id] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_RicoveriBase_DataPartizione] CHECK ([DataPartizione]<CONVERT([datetime],'20070101',(0)))
);














GO



GO



GO



GO





GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MAX(Eventi.DataModificaEsterno)  che compongono il ricovero', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RicoveriBase', @level2type = N'COLUMN', @level2name = N'DataModificaEsterno';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Prenotazione,1=Accettazione,2=In reparto,3=Dimissione,4=Riapertura,5=Cancellato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RicoveriBase', @level2type = N'COLUMN', @level2name = N'StatoCodice';


GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_IdEsterno]
    ON [dbo].[RicoveriBase]([IdEsterno] ASC)
    INCLUDE([Id], [DataPartizione], [DataModificaEsterno]) WITH (FILLFACTOR = 70);






GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_NumeroNosologico_AziendaErogante]
    ON [dbo].[RicoveriBase]([NumeroNosologico] ASC, [AziendaErogante] ASC) WITH (FILLFACTOR = 95);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_Id]
    ON [dbo].[RicoveriBase]([Id] ASC) WITH (FILLFACTOR = 70);




GO
CREATE NONCLUSTERED INDEX [IX_Stato_Reparto_Date]
    ON [dbo].[RicoveriBase]([StatoCodice] ASC, [RepartoCodice] ASC, [DataAccettazione] ASC, [DataDimissione] ASC) WITH (FILLFACTOR = 70);




GO
CREATE NONCLUSTERED INDEX [IX_Reparto_Tipo_Stato]
    ON [dbo].[RicoveriBase]([RepartoCodice] ASC, [TipoRicoveroCodice] ASC, [StatoCodice] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [FK_RicoveriBase_Pazienti]
    ON [dbo].[RicoveriBase]([IdPaziente] ASC, [TipoRicoveroCodice] ASC, [StatoCodice] ASC) WITH (FILLFACTOR = 70);

