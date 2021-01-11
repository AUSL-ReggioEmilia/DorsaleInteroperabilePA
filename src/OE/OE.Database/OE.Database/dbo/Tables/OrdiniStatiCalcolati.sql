CREATE TABLE [dbo].[OrdiniStatiCalcolati] (
    [Id]          INT          NOT NULL,
    [Codice]      VARCHAR (50) NOT NULL,
    [Descrizione] VARCHAR (50) NOT NULL,
    [Ordine]      INT          CONSTRAINT [DF_OrdiniStatiCalcolati_Ordine] DEFAULT ((1)) NOT NULL,
    [Attivo]      BIT          CONSTRAINT [DF_OrdiniStatiCalcolati_Attivo] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_OrdiniStatiCalcolati] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

