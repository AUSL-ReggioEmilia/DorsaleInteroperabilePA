CREATE TABLE [dbo].[AllegatiAttributi] (
    [IdAllegatiBase] UNIQUEIDENTIFIER NOT NULL,
    [Nome]           VARCHAR (64)     NOT NULL,
    [Valore]         SQL_VARIANT      NULL,
    [DataPartizione] SMALLDATETIME    NOT NULL,
    CONSTRAINT [PK_AllegatiAttributi] PRIMARY KEY CLUSTERED ([IdAllegatiBase] ASC, [Nome] ASC, [DataPartizione] ASC) WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE),
    CONSTRAINT [CK_AllegatiAttributi_DataPartizione] CHECK ([DataPartizione]>=CONVERT([smalldatetime],'20070101',(0))),
    CONSTRAINT [FK_AllegatiAttributi_AllegatiBase] FOREIGN KEY ([IdAllegatiBase], [DataPartizione]) REFERENCES [dbo].[AllegatiBase] ([ID], [DataPartizione]) ON DELETE CASCADE NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[AllegatiAttributi] NOCHECK CONSTRAINT [FK_AllegatiAttributi_AllegatiBase];

