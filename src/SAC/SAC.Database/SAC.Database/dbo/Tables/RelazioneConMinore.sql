CREATE TABLE [dbo].[RelazioneConMinore] (
    [Id]          INT           NOT NULL,
    [Descrizione] VARCHAR (128) NOT NULL,
    [Ordinamento] SMALLINT      NOT NULL,
    CONSTRAINT [PK_RelazioneConMinore] PRIMARY KEY CLUSTERED ([Id] ASC)
);

