CREATE TABLE [dbo].[NoteAnamnesticheBase] (
    [Id]                  UNIQUEIDENTIFIER NOT NULL,
    [DataPartizione]      SMALLDATETIME    NOT NULL,
    [IdEsterno]           VARCHAR (64)     NOT NULL,
    [IdPaziente]          UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]     DATETIME         NOT NULL,
    [DataModifica]        DATETIME         NOT NULL,
    [DataModificaEsterno] DATETIME         NULL,
    [StatoCodice]         TINYINT          NOT NULL,
    [AziendaErogante]     VARCHAR (16)     NOT NULL,
    [SistemaErogante]     VARCHAR (16)     NOT NULL,
    [DataNota]            DATETIME         NOT NULL,
    [DataFineValidita]    DATETIME         NULL,
    [TipoCodice]          VARCHAR (16)     NOT NULL,
    [TipoDescrizione]     VARCHAR (256)    NOT NULL,
    [Contenuto]           VARBINARY (MAX)  NOT NULL,
    [TipoContenuto]       VARCHAR (64)     NOT NULL,
    [ContenutoHtml]       VARCHAR (MAX)    NOT NULL,
    [ContenutoText]       VARCHAR (MAX)    NOT NULL,
    CONSTRAINT [PK_NoteAnamnesticheBase] PRIMARY KEY CLUSTERED ([DataPartizione] ASC, [Id] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_NoteAnamnesticheBase_DataPartizione] CHECK ([DataPartizione]<CONVERT([smalldatetime],'20070101',(0)))
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_IdEsterno]
    ON [dbo].[NoteAnamnesticheBase]([IdEsterno] ASC)
    INCLUDE([Id], [DataPartizione], [DataModificaEsterno]) WITH (FILLFACTOR = 70);


GO



GO
CREATE NONCLUSTERED INDEX [IX_DataNota_StatoCodice]
    ON [dbo].[NoteAnamnesticheBase]([DataNota] ASC, [StatoCodice] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_DataModifica_StatoCodice]
    ON [dbo].[NoteAnamnesticheBase]([DataModifica] ASC, [StatoCodice] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [FK_IdPaziente]
    ON [dbo].[NoteAnamnesticheBase]([IdPaziente] ASC, [DataNota] ASC, [StatoCodice] ASC) WITH (FILLFACTOR = 70);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_Id]
    ON [dbo].[NoteAnamnesticheBase]([Id] ASC) WITH (FILLFACTOR = 70);



