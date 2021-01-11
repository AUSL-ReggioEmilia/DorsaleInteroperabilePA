CREATE TABLE [dbo].[RicercaOrdiniCoda] (
    [IdSequenza]         INT              IDENTITY (1, 1) NOT NULL,
    [IdOrdineTestata]    UNIQUEIDENTIFIER NOT NULL,
    [DataInserimentoUtc] DATETIME2 (7)    CONSTRAINT [DF_RicercaOrdiniCoda_DataInserimentoUtc] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_RicercaOrdiniCoda] PRIMARY KEY CLUSTERED ([IdSequenza] ASC) WITH (FILLFACTOR = 70)
);

