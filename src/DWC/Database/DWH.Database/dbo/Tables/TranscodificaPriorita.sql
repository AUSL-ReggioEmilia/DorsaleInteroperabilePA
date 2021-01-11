CREATE TABLE [dbo].[TranscodificaPriorita] (
    [Id]              UNIQUEIDENTIFIER CONSTRAINT [DF_TranscodificaPriorita_Id] DEFAULT (newid()) NOT NULL,
    [AziendaErogante] VARCHAR (16)     NOT NULL,
    [SistemaErogante] VARCHAR (16)     NOT NULL,
    [CodiceEsterno]   VARCHAR (16)     NOT NULL,
    [Codice]          VARCHAR (16)     NOT NULL,
    [Descrizione]     VARCHAR (64)     NOT NULL,
    CONSTRAINT [PK_TranscodificaPriorita] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TranscodificaPriorita_AziendaErogante_SistemaErogante_CodiceEsterno]
    ON [dbo].[TranscodificaPriorita]([AziendaErogante] ASC, [SistemaErogante] ASC, [CodiceEsterno] ASC);

