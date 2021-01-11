CREATE TABLE [sole].[SistemiCartelle] (
    [Id]              UNIQUEIDENTIFIER CONSTRAINT [DF_SistemiCartelle_Id] DEFAULT (newid()) NOT NULL,
    [AziendaErogante] VARCHAR (16)     NOT NULL,
    [SistemaErogante] VARCHAR (16)     NOT NULL,
    [Abilitato]       BIT              CONSTRAINT [DF_SistemiCartelle_Abilitato] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SistemiCartelle] PRIMARY KEY CLUSTERED ([AziendaErogante] ASC, [SistemaErogante] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_SistemiCartelle_Id]
    ON [sole].[SistemiCartelle]([Id] ASC);

