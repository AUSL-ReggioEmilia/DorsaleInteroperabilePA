CREATE TABLE [dbo].[RicercaOrdiniCodaProcessate] (
    [Id]                 UNIQUEIDENTIFIER CONSTRAINT [DF_RicercaOrdiniCodaProcessate_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataProcessoUtc]    DATETIME2 (7)    CONSTRAINT [DF_RicercaOrdiniCodaProcessate_DataProcessoUtc] DEFAULT (getutcdate()) NOT NULL,
    [IdSequenza]         INT              NOT NULL,
    [IdOrdineTestata]    UNIQUEIDENTIFIER NOT NULL,
    [DataInserimentoUtc] DATETIME2 (7)    NOT NULL,
    CONSTRAINT [PK_RicercaOrdiniCodaProcessate] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70)
);

