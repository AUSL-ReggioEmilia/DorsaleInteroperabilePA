CREATE TABLE [dbo].[PrescrizioniAttributi] (
    [IdPrescrizioniBase] UNIQUEIDENTIFIER NOT NULL,
    [Nome]               VARCHAR (64)     NOT NULL,
    [Valore]             SQL_VARIANT      NULL,
    [DataPartizione]     SMALLDATETIME    NOT NULL,
    CONSTRAINT [PK_PrescrizioniAttributi] PRIMARY KEY CLUSTERED ([DataPartizione] ASC, [IdPrescrizioniBase] ASC, [Nome] ASC) WITH (FILLFACTOR = 70, DATA_COMPRESSION = PAGE),
    CONSTRAINT [CK_PrescrizioniAttributi_DataPartizione] CHECK ([DataPartizione]>=CONVERT([smalldatetime],'20070101',(0))),
    CONSTRAINT [FK_PrescrizioniAttributi_PrescrizioniBase] FOREIGN KEY ([DataPartizione], [IdPrescrizioniBase]) REFERENCES [dbo].[PrescrizioniBase] ([DataPartizione], [Id]) ON DELETE CASCADE NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[PrescrizioniAttributi] NOCHECK CONSTRAINT [FK_PrescrizioniAttributi_PrescrizioniBase];




GO
ALTER TABLE [dbo].[PrescrizioniAttributi] NOCHECK CONSTRAINT [FK_PrescrizioniAttributi_PrescrizioniBase];




GO
ALTER TABLE [dbo].[PrescrizioniAttributi] NOCHECK CONSTRAINT [FK_PrescrizioniAttributi_PrescrizioniBase];




GO
ALTER TABLE [dbo].[PrescrizioniAttributi] NOCHECK CONSTRAINT [FK_PrescrizioniAttributi_PrescrizioniBase];


GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_IdPrescrizioniBase_Nome]
    ON [dbo].[PrescrizioniAttributi]([IdPrescrizioniBase] ASC, [Nome] ASC) WITH (FILLFACTOR = 70);

