CREATE TABLE [dbo].[RicoveriAttributi] (
    [IdRicoveriBase] UNIQUEIDENTIFIER NOT NULL,
    [Nome]           VARCHAR (64)     NOT NULL,
    [Valore]         SQL_VARIANT      NULL,
    [DataPartizione] SMALLDATETIME    NOT NULL,
    CONSTRAINT [PK_RicoveriAttributi] PRIMARY KEY CLUSTERED ([DataPartizione] ASC, [IdRicoveriBase] ASC, [Nome] ASC) WITH (FILLFACTOR = 70, DATA_COMPRESSION = PAGE),
    CONSTRAINT [CK_RicoveriAttributi_DataPartizione] CHECK ([DataPartizione]>=CONVERT([datetime],'20070101',(0))),
    CONSTRAINT [FK_RicoveriAttributi_RicoveriBase] FOREIGN KEY ([DataPartizione], [IdRicoveriBase]) REFERENCES [dbo].[RicoveriBase] ([DataPartizione], [Id]) ON DELETE CASCADE NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[RicoveriAttributi] NOCHECK CONSTRAINT [FK_RicoveriAttributi_RicoveriBase];






GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_IdRicoveriBase_Nome]
    ON [dbo].[RicoveriAttributi]([IdRicoveriBase] ASC, [Nome] ASC) WITH (FILLFACTOR = 70);

