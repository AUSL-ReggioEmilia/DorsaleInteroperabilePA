CREATE TABLE [ara_svc].[CodaAnagraficheDaAggiornareInput] (
    [IdSequenza]         INT              IDENTITY (1, 1) NOT NULL,
    [DataInserimentoUtc] DATETIME         CONSTRAINT [DF_CodaAnagraficheDaAggiornareInputProcessate_DataInserimentoUtc] DEFAULT (getutcdate()) NOT NULL,
    [IdSac]              UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_CodaAnagraficheDaAggiornareInput] PRIMARY KEY CLUSTERED ([IdSequenza] ASC) WITH (FILLFACTOR = 70)
);

