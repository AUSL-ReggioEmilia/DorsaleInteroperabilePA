CREATE TABLE [dbo].[MotiviAccesso] (
    [Id]          INT           NOT NULL,
    [Descrizione] VARCHAR (128) NOT NULL,
    [Ordine]      SMALLINT      NOT NULL,
    CONSTRAINT [PK_MotiviAccesso] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

