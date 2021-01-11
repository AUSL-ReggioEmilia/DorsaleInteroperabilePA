CREATE TABLE [dbo].[RepartiRichiedenti] (
    [Id]                            UNIQUEIDENTIFIER CONSTRAINT [DF_RepartiRichiedenti_Id] DEFAULT (newid()) NOT NULL,
    [AziendaErogante]               VARCHAR (16)     NOT NULL,
    [RepartoRichiedenteCodice]      VARCHAR (16)     NOT NULL,
    [RepartoRichiedenteDescrizione] VARCHAR (64)     NULL,
    [RuoloVisualizzazione]          VARCHAR (128)    NULL,
    [RuoloManager]                  VARCHAR (128)    NULL,
    CONSTRAINT [PK_RepartiRichiedenti] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);



