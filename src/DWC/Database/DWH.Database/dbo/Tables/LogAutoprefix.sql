CREATE TABLE [dbo].[LogAutoprefix] (
    [Id]              INT          IDENTITY (1, 1) NOT NULL,
    [AziendaErogante] VARCHAR (16) NOT NULL,
    [SistemaErogante] VARCHAR (16) NOT NULL,
    [RepartoErogante] VARCHAR (64) NULL,
    [IdEsterno]       VARCHAR (64) NOT NULL,
    CONSTRAINT [PK_LogAutoprefix] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_LogAutoprefix]
    ON [dbo].[LogAutoprefix]([AziendaErogante] ASC, [SistemaErogante] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_LogAutoprefix_IdEsterno]
    ON [dbo].[LogAutoprefix]([IdEsterno] ASC);

