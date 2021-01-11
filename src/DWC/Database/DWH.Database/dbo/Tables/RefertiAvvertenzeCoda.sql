CREATE TABLE [dbo].[RefertiAvvertenzeCoda] (
    [IdSequenza]         INT              IDENTITY (1, 1) NOT NULL,
    [IdReferto]          UNIQUEIDENTIFIER NOT NULL,
    [DataInserimentoUtc] DATETIME2 (7)    CONSTRAINT [DF_RefertiAvvertenzeCoda_DataInserimentoUtc] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_RefertiAvvertenzeCoda] PRIMARY KEY CLUSTERED ([IdSequenza] ASC) WITH (FILLFACTOR = 70)
);

