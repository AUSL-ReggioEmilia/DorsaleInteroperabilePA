CREATE TABLE [dbo].[PrestazioniProfili] (
    [ID]       UNIQUEIDENTIFIER CONSTRAINT [DF_PrestazioniProfili_ID] DEFAULT (newid()) NOT NULL,
    [IDPadre]  UNIQUEIDENTIFIER NOT NULL,
    [IDFiglio] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_PrestazioniProfili] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_PrestazioniProfili_NonCircolari] CHECK NOT FOR REPLICATION ([dbo].[IsProfiloNelProfiloRecursivo]([IDFiglio],[IDPadre])=(0)),
    CONSTRAINT [FK_PrestazioniProfili_Prestazioni_IDFiglio] FOREIGN KEY ([IDFiglio]) REFERENCES [dbo].[Prestazioni] ([ID]),
    CONSTRAINT [FK_PrestazioniProfili_Prestazioni_IDPadre] FOREIGN KEY ([IDPadre]) REFERENCES [dbo].[Prestazioni] ([ID])
);




GO
CREATE UNIQUE CLUSTERED INDEX [IXC_IDPadreFigli]
    ON [dbo].[PrestazioniProfili]([IDPadre] ASC, [IDFiglio] ASC) WITH (FILLFACTOR = 70);

