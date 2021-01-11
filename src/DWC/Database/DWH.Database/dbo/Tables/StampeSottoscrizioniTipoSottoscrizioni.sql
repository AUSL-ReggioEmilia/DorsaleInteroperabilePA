CREATE TABLE [dbo].[StampeSottoscrizioniTipoSottoscrizioni] (
    [Id]          INT          NOT NULL,
    [Descrizione] VARCHAR (64) NULL,
    CONSTRAINT [PK_StampeSottoscrizioniTipoSottoscrizioni] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

