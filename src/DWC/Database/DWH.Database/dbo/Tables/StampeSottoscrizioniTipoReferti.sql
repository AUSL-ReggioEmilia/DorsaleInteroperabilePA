CREATE TABLE [dbo].[StampeSottoscrizioniTipoReferti] (
    [Id]          INT          NOT NULL,
    [Descrizione] VARCHAR (64) NULL,
    CONSTRAINT [PK_StampeSottoscrizioniTipoReferti] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

