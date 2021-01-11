CREATE TABLE [dbo].[PazientiPosizioneAss] (
    [Codice]      TINYINT      NOT NULL,
    [Descrizione] VARCHAR (16) NOT NULL,
    CONSTRAINT [PK_PazientiPosizioneAss] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);

