CREATE TABLE [dbo].[Tokens] (
    [Id]                   UNIQUEIDENTIFIER CONSTRAINT [DF_Tokens_Id] DEFAULT (newid()) NOT NULL,
    [DataInserimento]      DATETIME2 (0)    CONSTRAINT [DF_Tokens_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [CodiceRuolo]          VARCHAR (16)     NOT NULL,
    [IdRuolo]              UNIQUEIDENTIFIER NOT NULL,
    [UtenteProcesso]       VARCHAR (64)     NOT NULL,
    [UtenteDelegato]       VARCHAR (64)     NOT NULL,
    [CacheSistemiEroganti] XML              NULL,
    [CacheUnitaOperative]  XML              NULL,
    [CacheRuoliAccesso]    XML              NULL,
    CONSTRAINT [PK_Tokens] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);




GO
CREATE CLUSTERED INDEX [IXC_DataInserimento]
    ON [dbo].[Tokens]([DataInserimento] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RuoloUtente]
    ON [dbo].[Tokens]([CodiceRuolo] ASC, [UtenteProcesso] ASC, [UtenteDelegato] ASC, [DataInserimento] ASC)
    INCLUDE([Id]);

