CREATE TABLE [dbo].[UnitaOperative] (
    [ID]            UNIQUEIDENTIFIER NOT NULL,
    [Codice]        VARCHAR (16)     NOT NULL,
    [CodiceAzienda] VARCHAR (16)     NOT NULL,
    [Descrizione]   VARCHAR (128)    NULL,
    [Attivo]        BIT              NOT NULL,
    CONSTRAINT [PK_UnitaOperative] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Codice_Azienda]
    ON [dbo].[UnitaOperative]([Codice] ASC, [CodiceAzienda] ASC) WITH (FILLFACTOR = 70);

