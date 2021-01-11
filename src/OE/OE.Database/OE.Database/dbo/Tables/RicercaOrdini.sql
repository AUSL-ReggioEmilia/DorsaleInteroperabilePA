CREATE TABLE [dbo].[RicercaOrdini] (
    [IdSequenziale]                 UNIQUEIDENTIFIER CONSTRAINT [DF_RicercaOrdini_IdSequenziale] DEFAULT (newsequentialid()) NOT NULL,
    [IdOrdineTestata]               UNIQUEIDENTIFIER NOT NULL,
    [IdOrdineTestataErogata]        UNIQUEIDENTIFIER NOT NULL,
    [IdSistemaErogante]             UNIQUEIDENTIFIER NOT NULL,
    [SistemaEroganteDescrizione]    VARCHAR (32)     NOT NULL,
    [IdSistemaRichiedente]          UNIQUEIDENTIFIER NOT NULL,
    [SistemaRichiedenteDescrizione] VARCHAR (32)     NOT NULL,
    [IdUnitaOperativa]              UNIQUEIDENTIFIER NOT NULL,
    [UnitaOperativaDescrizione]     VARCHAR (32)     NOT NULL,
    [OrderEntryStato]               VARCHAR (16)     NOT NULL,
    [OrderEntryStatoDescrizione]    VARCHAR (64)     NULL,
    [DataModificaStato]             DATETIME2 (7)    NULL,
    [DataPrenotazioneRichiesta]     DATETIME2 (7)    NULL,
    [DataPrenotazioneErogante]      DATETIME2 (7)    NULL,
    [DataPianificazioneErogante]    DATETIME2 (7)    NULL,
    [DataModificaPianificazione]    DATETIME2 (7)    NULL,
    CONSTRAINT [PK_RicercaOrdini] PRIMARY KEY NONCLUSTERED ([IdOrdineTestata] ASC, [IdOrdineTestataErogata] ASC) WITH (FILLFACTOR = 70)
);




GO



GO



GO



GO
CREATE UNIQUE CLUSTERED INDEX [IXC_IdSequenziale]
    ON [dbo].[RicercaOrdini]([IdSequenziale] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OrderEntryStato_IdSistemaErogante_Date]
    ON [dbo].[RicercaOrdini]([OrderEntryStato] ASC, [IdSistemaErogante] ASC)
    INCLUDE([DataPrenotazioneRichiesta], [DataPrenotazioneErogante], [DataPianificazioneErogante], [DataModificaPianificazione], [IdOrdineTestata]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IdUnitaOperativa_IdSistemaErogante]
    ON [dbo].[RicercaOrdini]([IdUnitaOperativa] ASC, [IdSistemaErogante] ASC) WITH (FILLFACTOR = 70);

