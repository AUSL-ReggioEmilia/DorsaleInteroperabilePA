CREATE TABLE [dbo].[TipiReferto] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [SistemaErogante]    VARCHAR (16)     NOT NULL,
    [SpecialitaErogante] VARCHAR (64)     NULL,
    [Descrizione]        VARCHAR (128)    NOT NULL,
    [Icona]              VARBINARY (MAX)  NOT NULL,
    [Ordinamento]        INT              CONSTRAINT [DF_TipiReferto_Ordinamento] DEFAULT ((0)) NOT NULL,
    [AziendaErogante]    VARCHAR (16)     CONSTRAINT [DF_TipiReferto_AziendaErogante] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_TipiReferto] PRIMARY KEY CLUSTERED ([Id] ASC)
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TipiReferto]
    ON [dbo].[TipiReferto]([AziendaErogante] ASC, [SistemaErogante] ASC, [SpecialitaErogante] ASC);





