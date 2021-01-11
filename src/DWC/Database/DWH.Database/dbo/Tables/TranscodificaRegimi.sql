CREATE TABLE [dbo].[TranscodificaRegimi] (
    [Id]              UNIQUEIDENTIFIER CONSTRAINT [DF_TranscodificaRegimi_Id] DEFAULT (newid()) NOT NULL,
    [AziendaErogante] VARCHAR (16)     NOT NULL,
    [SistemaErogante] VARCHAR (16)     NOT NULL,
    [CodiceEsterno]   VARCHAR (16)     NOT NULL,
    [Codice]          VARCHAR (16)     NOT NULL,
    [Descrizione]     VARCHAR (64)     NOT NULL,
    CONSTRAINT [PK_TranscodificaRegimi] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TranscodificaRegimi_AziendaErogante_SistemaErogante_CodiceEsterno]
    ON [dbo].[TranscodificaRegimi]([AziendaErogante] ASC, [SistemaErogante] ASC, [CodiceEsterno] ASC);

