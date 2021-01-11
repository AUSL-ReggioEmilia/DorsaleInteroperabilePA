CREATE TABLE [ara_svc].[CodaAnagraficheDaAggiornareProcessati] (
    [Id]                 UNIQUEIDENTIFIER CONSTRAINT [DF_CodaAnagraficheDaAggiornareProcessate_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataProcessoUtc]    DATETIME         CONSTRAINT [DF_CodaAnagraficheDaAggiornareProcessate_DataProcessoUtc] DEFAULT (getutcdate()) NOT NULL,
    [IdSequenza]         INT              NOT NULL,
    [DataInserimentoUtc] DATETIME         NOT NULL,
    [IdSac]              UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_CodaAnagraficheDaAggiornareProcessati] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70)
);

