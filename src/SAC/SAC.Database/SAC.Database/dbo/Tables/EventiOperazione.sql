CREATE TABLE [dbo].[EventiOperazione] (
    [Id]          TINYINT      NOT NULL,
    [Descrizione] VARCHAR (32) NOT NULL,
    CONSTRAINT [PK_EventiOperazione] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

