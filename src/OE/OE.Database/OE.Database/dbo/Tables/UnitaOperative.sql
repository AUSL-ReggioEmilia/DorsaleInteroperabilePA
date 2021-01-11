CREATE TABLE [dbo].[UnitaOperative] (
    [ID]            UNIQUEIDENTIFIER NOT NULL,
    [Codice]        VARCHAR (16)     NOT NULL,
    [CodiceAzienda] VARCHAR (16)     NOT NULL,
    [Descrizione]   VARCHAR (128)    NULL,
    [Attivo]        BIT              CONSTRAINT [DF_UnitaOperative_Attivo] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_UnitaOperative] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_Codice_Azienda]
    ON [dbo].[UnitaOperative]([Codice] ASC, [CodiceAzienda] ASC) WITH (FILLFACTOR = 70);

