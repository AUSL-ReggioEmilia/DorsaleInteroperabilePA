CREATE TABLE [dbo].[Sistemi] (
    [ID]                        UNIQUEIDENTIFIER NOT NULL,
    [Codice]                    VARCHAR (16)     NOT NULL,
    [CodiceAzienda]             VARCHAR (16)     NOT NULL,
    [Descrizione]               VARCHAR (128)    NULL,
    [Richiedente]               BIT              NOT NULL,
    [Erogante]                  BIT              NOT NULL,
    [Attivo]                    BIT              NOT NULL,
    [CancellazionePostInoltro]  BIT              NOT NULL,
    [CancellazionePostInCarico] BIT              NOT NULL,
    CONSTRAINT [PK_Sistemi] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Codice_Azienda]
    ON [dbo].[Sistemi]([Codice] ASC, [CodiceAzienda] ASC) WITH (FILLFACTOR = 70);

