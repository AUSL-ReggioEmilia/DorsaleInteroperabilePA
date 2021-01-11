CREATE TABLE [dbo].[PrescrizioniBase] (
    [Id]                              UNIQUEIDENTIFIER NOT NULL,
    [DataPartizione]                  SMALLDATETIME    NOT NULL,
    [IdEsterno]                       VARCHAR (64)     NOT NULL,
    [IdPaziente]                      UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]                 DATETIME         NOT NULL,
    [DataModifica]                    DATETIME         NOT NULL,
    [DataModificaEsterno]             DATETIME         NULL,
    [StatoCodice]                     TINYINT          NOT NULL,
    [TipoPrescrizione]                VARCHAR (32)     NOT NULL,
    [DataPrescrizione]                DATETIME         NOT NULL,
    [NumeroPrescrizione]              VARCHAR (16)     NOT NULL,
    [MedicoPrescrittoreCodiceFiscale] VARCHAR (16)     NOT NULL,
    [QuesitoDiagnostico]              VARCHAR (2048)   NULL,
    CONSTRAINT [PK_PrescrizioniBase] PRIMARY KEY CLUSTERED ([DataPartizione] ASC, [Id] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_PrescrizioniBase_DataPartizione] CHECK ([DataPartizione]<CONVERT([smalldatetime],'20070101',(0)))
);










GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_IdEsterno]
    ON [dbo].[PrescrizioniBase]([IdEsterno] ASC) WITH (FILLFACTOR = 70);




GO
CREATE NONCLUSTERED INDEX [IX_DataPrescrizione_StatoCodice]
    ON [dbo].[PrescrizioniBase]([DataPrescrizione] ASC, [StatoCodice] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_DataModifica_StatoCodice]
    ON [dbo].[PrescrizioniBase]([DataModifica] ASC, [StatoCodice] ASC) WITH (FILLFACTOR = 70);


GO





GO
CREATE NONCLUSTERED INDEX [FK_IdPaziente]
    ON [dbo].[PrescrizioniBase]([IdPaziente] ASC, [DataPrescrizione] ASC, [StatoCodice] ASC) WITH (FILLFACTOR = 70);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_Id]
    ON [dbo].[PrescrizioniBase]([Id] ASC) WITH (FILLFACTOR = 70);



