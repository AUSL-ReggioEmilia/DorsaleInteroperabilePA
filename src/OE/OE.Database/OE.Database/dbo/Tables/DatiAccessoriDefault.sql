CREATE TABLE [dbo].[DatiAccessoriDefault] (
    [Codice]      VARCHAR (32)  NOT NULL,
    [Descrizione] VARCHAR (128) NULL,
    [Attivo]      BIT           CONSTRAINT [DF_DatiAccessoriDefault_Attivo] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DatiAccessoriDefault] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);

