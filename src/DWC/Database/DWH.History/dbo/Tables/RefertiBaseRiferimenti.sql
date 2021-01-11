CREATE TABLE [dbo].[RefertiBaseRiferimenti] (
    [Id]                  UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL,
    [DataPartizione]      SMALLDATETIME    NOT NULL,
    [IdRefertiBase]       UNIQUEIDENTIFIER NOT NULL,
    [IdEsterno]           VARCHAR (64)     NOT NULL,
    [DataInserimento]     DATETIME         CONSTRAINT [DF_RefertiBaseRiferimenti_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModificaEsterno] DATETIME         NOT NULL,
    CONSTRAINT [PK_RefertiBaseRiferimenti] PRIMARY KEY NONCLUSTERED ([Id] ASC, [DataPartizione] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_RefertiBaseRiferimenti_DataPartizione] CHECK ([DataPartizione]<CONVERT([smalldatetime],'20070101',(0))),
    CONSTRAINT [FK_RefertiBaseRiferimenti_RefertiBase] FOREIGN KEY ([IdRefertiBase], [DataPartizione]) REFERENCES [dbo].[RefertiBase] ([Id], [DataPartizione]) ON DELETE CASCADE NOT FOR REPLICATION
);






GO



GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_IdEsterno]
    ON [dbo].[RefertiBaseRiferimenti]([IdEsterno] ASC)
    INCLUDE([Id], [DataPartizione], [DataModificaEsterno]) WITH (FILLFACTOR = 70);




GO
CREATE UNIQUE CLUSTERED INDEX [IXC_IdRefertiBase_IdEsterno]
    ON [dbo].[RefertiBaseRiferimenti]([IdRefertiBase] ASC, [IdEsterno] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [FK_IdRefertiBase]
    ON [dbo].[RefertiBaseRiferimenti]([DataPartizione] ASC, [IdRefertiBase] ASC) WITH (FILLFACTOR = 70);



