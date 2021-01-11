CREATE TABLE [dbo].[PrestazioniAttributi] (
    [IdPrestazioniBase] UNIQUEIDENTIFIER NOT NULL,
    [Nome]              VARCHAR (64)     NOT NULL,
    [Valore]            SQL_VARIANT      NULL,
    [DataPartizione]    SMALLDATETIME    NOT NULL,
    CONSTRAINT [PK_PrestazioniAttributi] PRIMARY KEY CLUSTERED ([IdPrestazioniBase] ASC, [Nome] ASC, [DataPartizione] ASC) WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE),
    CONSTRAINT [CK_PrestazioniAttributi_DataPartizione] CHECK ([DataPartizione]>=CONVERT([smalldatetime],'20070101',(0))),
    CONSTRAINT [FK_PrestazioniAttributi_PrestazioniBase] FOREIGN KEY ([IdPrestazioniBase], [DataPartizione]) REFERENCES [dbo].[PrestazioniBase] ([ID], [DataPartizione]) ON DELETE CASCADE NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[PrestazioniAttributi] NOCHECK CONSTRAINT [FK_PrestazioniAttributi_PrestazioniBase];

