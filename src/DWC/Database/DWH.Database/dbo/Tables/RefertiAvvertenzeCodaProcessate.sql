CREATE TABLE [dbo].[RefertiAvvertenzeCodaProcessate] (
    [Id]                 UNIQUEIDENTIFIER CONSTRAINT [DF_RefertiAvvertenzeCodaProcessate_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataProcessoUtc]    DATETIME2 (7)    CONSTRAINT [DF_RefertiAvvertenzeCodaProcessate_DataProcessoUtc] DEFAULT (getutcdate()) NOT NULL,
    [IdSequenza]         INT              NOT NULL,
    [IdReferto]          UNIQUEIDENTIFIER NOT NULL,
    [DataInserimentoUtc] DATETIME2 (7)    NOT NULL,
    CONSTRAINT [PK_RefertiAvvertenzeCodaProcessate] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70)
);

