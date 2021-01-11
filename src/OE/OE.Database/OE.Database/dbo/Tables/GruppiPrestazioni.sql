CREATE TABLE [dbo].[GruppiPrestazioni] (
    [ID]          UNIQUEIDENTIFIER CONSTRAINT [DF_GruppiPrestazioni_ID] DEFAULT (newid()) NOT NULL,
    [Descrizione] VARCHAR (128)    NOT NULL,
    [Preferiti]   BIT              CONSTRAINT [DF_GruppiPrestazioni_Preferiti] DEFAULT ((0)) NOT NULL,
    [Note]        VARCHAR (1024)   NULL,
    CONSTRAINT [PK_GruppiPrestazioni] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);



