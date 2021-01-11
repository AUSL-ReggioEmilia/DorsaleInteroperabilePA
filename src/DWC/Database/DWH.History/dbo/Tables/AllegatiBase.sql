CREATE TABLE [dbo].[AllegatiBase] (
    [ID]                    UNIQUEIDENTIFIER NOT NULL,
    [IdRefertiBase]         UNIQUEIDENTIFIER NOT NULL,
    [IdEsterno]             VARCHAR (64)     NOT NULL,
    [DataInserimento]       DATETIME         NOT NULL,
    [DataModifica]          DATETIME         NOT NULL,
    [DataFile]              DATETIME         NULL,
    [MimeType]              VARCHAR (50)     NULL,
    [DataPartizione]        SMALLDATETIME    NOT NULL,
    [MimeDataCompresso]     VARBINARY (MAX)  NULL,
    [MimeStatoCompressione] TINYINT          NOT NULL,
    [MimeDataOriginale]     VARBINARY (MAX)  NULL,
    [MimeData]              IMAGE            NULL,
    CONSTRAINT [PK_AllegatiBase] PRIMARY KEY NONCLUSTERED ([ID] ASC, [DataPartizione] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [CK_AllegatiBase_DataPartizione] CHECK ([DataPartizione]<CONVERT([smalldatetime],'20070101',0)),
    CONSTRAINT [FK_AllegatiBase_RefertiBase] FOREIGN KEY ([IdRefertiBase], [DataPartizione]) REFERENCES [dbo].[RefertiBase] ([Id], [DataPartizione]) NOT FOR REPLICATION
);




GO
CREATE UNIQUE CLUSTERED INDEX [FK_RefertoBase_IdEsterno]
    ON [dbo].[AllegatiBase]([IdRefertiBase] ASC, [IdEsterno] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_MimeStatoComp_MimeType]
    ON [dbo].[AllegatiBase]([MimeStatoCompressione] ASC, [MimeType] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [FK_RefertoBase_Referti]
    ON [dbo].[AllegatiBase]([DataPartizione] ASC, [IdRefertiBase] ASC) WITH (FILLFACTOR = 95);

