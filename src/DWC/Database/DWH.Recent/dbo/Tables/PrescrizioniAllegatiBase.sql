CREATE TABLE [dbo].[PrescrizioniAllegatiBase] (
    [ID]                 UNIQUEIDENTIFIER NOT NULL,
    [DataPartizione]     SMALLDATETIME    NOT NULL,
    [IdPrescrizioniBase] UNIQUEIDENTIFIER NOT NULL,
    [IdEsterno]          VARCHAR (64)     NOT NULL,
    [DataInserimento]    DATETIME         NOT NULL,
    [DataModifica]       DATETIME         NOT NULL,
    [TipoContenuto]      VARCHAR (64)     NOT NULL,
    [ContenutoCompresso] VARBINARY (MAX)  NOT NULL,
    CONSTRAINT [PK_PrescrizioniAllegatiBase] PRIMARY KEY CLUSTERED ([DataPartizione] ASC, [ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_PrescrizioniAllegatiBase_DataPartizione] CHECK ([DataPartizione]>=CONVERT([smalldatetime],'20070101',(0))),
    CONSTRAINT [FK_PrescrizioniAllegati_PrescrizioniBase] FOREIGN KEY ([DataPartizione], [IdPrescrizioniBase]) REFERENCES [dbo].[PrescrizioniBase] ([DataPartizione], [Id]) NOT FOR REPLICATION
);








GO



GO



GO



GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_IdPrescrizioni_IdEsterno]
    ON [dbo].[PrescrizioniAllegatiBase]([IdPrescrizioniBase] ASC, [IdEsterno] ASC) WITH (FILLFACTOR = 70);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_Id]
    ON [dbo].[PrescrizioniAllegatiBase]([ID] ASC) WITH (FILLFACTOR = 70);

