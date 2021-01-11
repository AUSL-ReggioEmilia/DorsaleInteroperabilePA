CREATE TABLE [dbo].[Sistemi] (
    [ID]                        UNIQUEIDENTIFIER NOT NULL,
    [Codice]                    VARCHAR (16)     NOT NULL,
    [CodiceAzienda]             VARCHAR (16)     NOT NULL,
    [Descrizione]               VARCHAR (128)    NULL,
    [Richiedente]               BIT              CONSTRAINT [DF_Sistemi_Richiedente] DEFAULT ((1)) NOT NULL,
    [Erogante]                  BIT              CONSTRAINT [DF_Sistemi_Erogante] DEFAULT ((0)) NOT NULL,
    [Attivo]                    BIT              CONSTRAINT [DF_Sistemi_Attivo] DEFAULT ((1)) NOT NULL,
    [CancellazionePostInoltro]  BIT              CONSTRAINT [DF_Sistemi_CancellazionePostInoltro] DEFAULT ((0)) NOT NULL,
    [CancellazionePostInCarico] BIT              CONSTRAINT [DF_Sistemi_CancellazionePostInCarico] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Sistemi] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);




GO
CREATE UNIQUE CLUSTERED INDEX [IX_Codice_Azienda]
    ON [dbo].[Sistemi]([Codice] ASC, [CodiceAzienda] ASC) WITH (FILLFACTOR = 70);

