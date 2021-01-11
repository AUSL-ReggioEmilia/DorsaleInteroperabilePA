CREATE TABLE [dbo].[PrestazioniBase] (
    [ID]                     UNIQUEIDENTIFIER NOT NULL,
    [IdRefertiBase]          UNIQUEIDENTIFIER NOT NULL,
    [IdEsterno]              VARCHAR (64)     NOT NULL,
    [DataInserimento]        DATETIME         NOT NULL,
    [DataModifica]           DATETIME         NOT NULL,
    [DataErogazione]         DATETIME         NULL,
    [PrestazioneCodice]      VARCHAR (12)     NULL,
    [PrestazioneDescrizione] VARCHAR (150)    NULL,
    [SoundexPrestazione]     VARCHAR (4)      NULL,
    [SezioneCodice]          VARCHAR (12)     NULL,
    [SezioneDescrizione]     VARCHAR (255)    NULL,
    [SoundexSezione]         VARCHAR (4)      NULL,
    [DataPartizione]         SMALLDATETIME    NOT NULL,
    CONSTRAINT [PK_PrestazioniBase] PRIMARY KEY NONCLUSTERED ([ID] ASC, [DataPartizione] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_PrestazioniBase_DataPartizione] CHECK ([DataPartizione]>=CONVERT([smalldatetime],'20070101',(0))),
    CONSTRAINT [FK_PrestazioniBase_RefertiBase] FOREIGN KEY ([IdRefertiBase], [DataPartizione]) REFERENCES [dbo].[RefertiBase] ([Id], [DataPartizione]) NOT FOR REPLICATION
);






GO
CREATE UNIQUE CLUSTERED INDEX [FK_RefertiBase_IdEsterno]
    ON [dbo].[PrestazioniBase]([IdRefertiBase] ASC, [IdEsterno] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Oscuramento_Parola]
    ON [dbo].[PrestazioniBase]([DataPartizione] ASC, [IdRefertiBase] ASC)
    INCLUDE([PrestazioneDescrizione], [SezioneDescrizione]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_PrestazioneCodice]
    ON [dbo].[PrestazioniBase]([PrestazioneCodice] ASC) WITH (FILLFACTOR = 40);


GO


