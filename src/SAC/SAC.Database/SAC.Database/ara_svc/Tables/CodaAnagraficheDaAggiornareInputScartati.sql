CREATE TABLE [ara_svc].[CodaAnagraficheDaAggiornareInputScartati] (
    [Id]                 UNIQUEIDENTIFIER CONSTRAINT [DF_CodaAnagraficheDaAggiornareInputScartati_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataProcessoUtc]    DATETIME         CONSTRAINT [DF_CodaAnagraficheDaAggiornareInputScartati_DataProcessoUtc] DEFAULT (getutcdate()) NOT NULL,
    [IdSequenza]         INT              NOT NULL,
    [DataInserimentoUtc] DATETIME         CONSTRAINT [DF_CodaAnagraficheDaAggiornareInputScartati_DataInserimentoUtc] DEFAULT (getutcdate()) NOT NULL,
    [IdSac]              UNIQUEIDENTIFIER NOT NULL,
    [Motivo]             VARCHAR (1024)   NOT NULL,
    CONSTRAINT [PK_CodaAnagraficheDaAggiornareInputScartati] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70)
);



