CREATE TABLE [dbo].[RefertiAvvertenzeCodaProcessateErrore] (
    [Id]                 UNIQUEIDENTIFIER CONSTRAINT [DF_RefertiAvvertenzeCodaProcessateErrore_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataProcessoUtc]    DATETIME2 (7)    CONSTRAINT [DF_RefertiAvvertenzeCodaProcessateErrore_DataProcessoUtc] DEFAULT (getutcdate()) NOT NULL,
    [IdSequenza]         INT              NOT NULL,
    [IdReferto]          UNIQUEIDENTIFIER NOT NULL,
    [DataInserimentoUtc] DATETIME2 (7)    NOT NULL,
    [Errore]             VARCHAR (4096)   NULL,
    CONSTRAINT [PK_RefertiAvvertenzeCodaProcessateErrore] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70)
);



