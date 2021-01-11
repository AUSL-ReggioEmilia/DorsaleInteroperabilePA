CREATE TABLE [dbo].[GruppiUtenti] (
    [ID]          UNIQUEIDENTIFIER CONSTRAINT [DF_GruppiUtenti_ID] DEFAULT (newid()) NOT NULL,
    [Descrizione] VARCHAR (128)    NOT NULL,
    [Note]        VARCHAR (1024)   NULL,
    CONSTRAINT [PK_GruppiUtenti] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);



