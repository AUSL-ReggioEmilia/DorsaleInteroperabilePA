CREATE TABLE [dbo].[DatiAccessoriTipi] (
    [Id]          INT          NOT NULL,
    [Codice]      VARCHAR (50) NOT NULL,
    [Descrizione] VARCHAR (50) NOT NULL,
    [Ordine]      INT          CONSTRAINT [DF_DatiAccessoriTipi_Ordine] DEFAULT ((1)) NOT NULL,
    [Attivo]      BIT          CONSTRAINT [DF_DatiAccessoriTipi_Attivo] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DatiAccessoriTipi] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70)
);



