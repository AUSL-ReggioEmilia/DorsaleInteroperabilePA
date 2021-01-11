CREATE TABLE [dbo].[PazientiAnteprima] (
    [IdPaziente]                                UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]                           DATETIME         CONSTRAINT [DF_PazientiAnteprima_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [CalcolaAnteprimaReferti]                   DATETIME         CONSTRAINT [DF_PazientiAnteprima_CalcolaAnteprimaReferti] DEFAULT (getdate()) NULL,
    [DataModificaAnteprimaReferti]              DATETIME         NULL,
    [AnteprimaReferti]                          VARCHAR (2048)   NULL,
    [CalcolaAnteprimaRicoveri]                  DATETIME         CONSTRAINT [DF_PazientiAnteprima_CalcolaAnteprimaRicoveri] DEFAULT (getdate()) NULL,
    [DataModificaAnteprimaRicoveri]             DATETIME         NULL,
    [AnteprimaRicoveri]                         VARCHAR (2048)   NULL,
    [PatientSummaryPdf]                         VARBINARY (MAX)  NULL,
    [PatientSummaryDataModifica]                DATETIME         NULL,
    [PatientSummaryErrore]                      VARCHAR (4096)   NULL,
    [PatientSummaryCda]                         VARBINARY (MAX)  NULL,
    [IdUltimoRicovero]                          UNIQUEIDENTIFIER NULL,
    [CalcolaAnteprimaNoteAnamnestiche]          DATETIME         CONSTRAINT [DF_PazientiAnteprima_CalcolaAnteprimaNoteAnamnestiche] DEFAULT (getdate()) NULL,
    [DataModificaAnteprimaNoteAnamnestiche]     DATETIME         NULL,
    [NumeroNoteAnamnestiche]                    INT              CONSTRAINT [DF_PazientiAnteprima_NumeroNoteAnamnestiche] DEFAULT ((0)) NOT NULL,
    [UltimaNotaAnamnesticaData]                 DATETIME         NULL,
    [UltimaNotaAnamnesticaSistemaEroganteDescr] VARCHAR (128)    NULL,
    CONSTRAINT [PK_PazientiAnteprima] PRIMARY KEY CLUSTERED ([IdPaziente] ASC) WITH (FILLFACTOR = 90)
);






GO
CREATE NONCLUSTERED INDEX [IX_PazientiAnteprima_CalcolaAnteprimaReferti]
    ON [dbo].[PazientiAnteprima]([CalcolaAnteprimaReferti] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiAnteprima_CalcolaAnteprimaRicoveri]
    ON [dbo].[PazientiAnteprima]([CalcolaAnteprimaRicoveri] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiAnteprima_CalcolaAnteprimaNoteAnamnestiche]
    ON [dbo].[PazientiAnteprima]([CalcolaAnteprimaNoteAnamnestiche] ASC);

