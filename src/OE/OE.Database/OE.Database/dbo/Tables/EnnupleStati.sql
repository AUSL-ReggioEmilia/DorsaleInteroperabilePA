CREATE TABLE [dbo].[EnnupleStati] (
    [ID]          TINYINT        NOT NULL,
    [Descrizione] VARCHAR (64)   NOT NULL,
    [Note]        VARCHAR (1024) NULL,
    CONSTRAINT [PK_EnnupleStati] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);



