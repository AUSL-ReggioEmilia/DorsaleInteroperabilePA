CREATE TABLE [dbo].[PrestazioniGruppiPrestazioni] (
    [ID]                  UNIQUEIDENTIFIER CONSTRAINT [DF_PrestazioniGruppiPrestazioni_ID] DEFAULT (newid()) NOT NULL,
    [IDPrestazione]       UNIQUEIDENTIFIER NOT NULL,
    [IDGruppoPrestazioni] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_PrestazioniGruppiPrestazioni] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_PrestazioniGruppiPrestazioni_GruppiPrestazioni] FOREIGN KEY ([IDGruppoPrestazioni]) REFERENCES [dbo].[GruppiPrestazioni] ([ID]),
    CONSTRAINT [FK_PrestazioniGruppiPrestazioni_Prestazioni] FOREIGN KEY ([IDPrestazione]) REFERENCES [dbo].[Prestazioni] ([ID])
);




GO



GO
CREATE NONCLUSTERED INDEX [IX_IDPrestazione]
    ON [dbo].[PrestazioniGruppiPrestazioni]([IDPrestazione] ASC)
    INCLUDE([IDGruppoPrestazioni]) WITH (FILLFACTOR = 90);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_IDGruppoPrestazioni]
    ON [dbo].[PrestazioniGruppiPrestazioni]([IDGruppoPrestazioni] ASC, [IDPrestazione] ASC) WITH (FILLFACTOR = 70);

