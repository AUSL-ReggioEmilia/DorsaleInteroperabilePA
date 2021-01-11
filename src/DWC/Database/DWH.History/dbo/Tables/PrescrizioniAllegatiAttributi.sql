CREATE TABLE [dbo].[PrescrizioniAllegatiAttributi] (
    [IdPrescrizioniAllegatiBase] UNIQUEIDENTIFIER NOT NULL,
    [Nome]                       VARCHAR (64)     NOT NULL,
    [Valore]                     SQL_VARIANT      NULL,
    [DataPartizione]             SMALLDATETIME    NOT NULL,
    CONSTRAINT [PK_PrescrizioniAllegatiAttributi] PRIMARY KEY CLUSTERED ([DataPartizione] ASC, [IdPrescrizioniAllegatiBase] ASC, [Nome] ASC) WITH (FILLFACTOR = 70, DATA_COMPRESSION = PAGE),
    CONSTRAINT [CK_PrescrizioniAllegatiAttributi_DataPartizione] CHECK ([DataPartizione]<CONVERT([smalldatetime],'20070101',(0))),
    CONSTRAINT [FK_PrescrizioniAllegatiAttributi_PrescrizioniAllegatiBase] FOREIGN KEY ([DataPartizione], [IdPrescrizioniAllegatiBase]) REFERENCES [dbo].[PrescrizioniAllegatiBase] ([DataPartizione], [ID]) ON DELETE CASCADE NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[PrescrizioniAllegatiAttributi] NOCHECK CONSTRAINT [FK_PrescrizioniAllegatiAttributi_PrescrizioniAllegatiBase];




GO
ALTER TABLE [dbo].[PrescrizioniAllegatiAttributi] NOCHECK CONSTRAINT [FK_PrescrizioniAllegatiAttributi_PrescrizioniAllegatiBase];




GO
ALTER TABLE [dbo].[PrescrizioniAllegatiAttributi] NOCHECK CONSTRAINT [FK_PrescrizioniAllegatiAttributi_PrescrizioniAllegatiBase];




GO
ALTER TABLE [dbo].[PrescrizioniAllegatiAttributi] NOCHECK CONSTRAINT [FK_PrescrizioniAllegatiAttributi_PrescrizioniAllegatiBase];




GO
ALTER TABLE [dbo].[PrescrizioniAllegatiAttributi] NOCHECK CONSTRAINT [FK_PrescrizioniAllegatiAttributi_PrescrizioniAllegatiBase];


GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_IdPrescrizione_Nome]
    ON [dbo].[PrescrizioniAllegatiAttributi]([IdPrescrizioniAllegatiBase] ASC, [Nome] ASC) WITH (FILLFACTOR = 70, DATA_COMPRESSION = PAGE);



