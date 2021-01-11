CREATE TABLE [dbo].[QueueOperazione] (
    [Id]          TINYINT      NOT NULL,
    [Descrizione] VARCHAR (32) NOT NULL,
    CONSTRAINT [PK_QueueOperazione] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

