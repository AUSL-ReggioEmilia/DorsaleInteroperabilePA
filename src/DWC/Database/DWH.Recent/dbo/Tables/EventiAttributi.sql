CREATE TABLE [dbo].[EventiAttributi] (
    [IdEventiBase]   UNIQUEIDENTIFIER NOT NULL,
    [Nome]           VARCHAR (64)     NOT NULL,
    [Valore]         SQL_VARIANT      NULL,
    [DataPartizione] SMALLDATETIME    NOT NULL,
    CONSTRAINT [PK_EventiAttributi] PRIMARY KEY CLUSTERED ([IdEventiBase] ASC, [Nome] ASC, [DataPartizione] ASC) WITH (FILLFACTOR = 70, DATA_COMPRESSION = PAGE),
    CONSTRAINT [CK_EventiAttributi_DataPartizione] CHECK ([DataPartizione]>=CONVERT([datetime],'20070101',(0))),
    CONSTRAINT [FK_EventiAttributi_EventiBase] FOREIGN KEY ([IdEventiBase], [DataPartizione]) REFERENCES [dbo].[EventiBase] ([Id], [DataPartizione]) ON DELETE CASCADE NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[EventiAttributi] NOCHECK CONSTRAINT [FK_EventiAttributi_EventiBase];





