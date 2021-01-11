CREATE TABLE [dbo].[RefertiAttributi] (
    [IdRefertiBase]  UNIQUEIDENTIFIER NOT NULL,
    [Nome]           VARCHAR (64)     NOT NULL,
    [Valore]         SQL_VARIANT      NULL,
    [DataPartizione] SMALLDATETIME    NOT NULL,
    CONSTRAINT [PK_RefertiAttributi] PRIMARY KEY CLUSTERED ([IdRefertiBase] ASC, [Nome] ASC, [DataPartizione] ASC) WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE),
    CONSTRAINT [CK_RefertiAttributi_DataPartizione] CHECK ([DataPartizione]>=CONVERT([smalldatetime],'20070101',(0))),
    CONSTRAINT [FK_RefertiAttributi_RefertiBase] FOREIGN KEY ([IdRefertiBase], [DataPartizione]) REFERENCES [dbo].[RefertiBase] ([Id], [DataPartizione]) ON DELETE CASCADE NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[RefertiAttributi] NOCHECK CONSTRAINT [FK_RefertiAttributi_RefertiBase];

