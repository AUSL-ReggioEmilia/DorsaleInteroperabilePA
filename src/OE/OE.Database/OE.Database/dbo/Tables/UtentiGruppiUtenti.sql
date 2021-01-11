CREATE TABLE [dbo].[UtentiGruppiUtenti] (
    [ID]             UNIQUEIDENTIFIER CONSTRAINT [DF_UtentiGruppiUtenti_ID] DEFAULT (newid()) NOT NULL,
    [IDUtente]       UNIQUEIDENTIFIER NOT NULL,
    [IDGruppoUtenti] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_UtentiGruppiUtenti] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_UtentiGruppiUtenti_GruppiUtenti] FOREIGN KEY ([IDGruppoUtenti]) REFERENCES [dbo].[GruppiUtenti] ([ID]),
    CONSTRAINT [FK_UtentiGruppiUtenti_Utenti] FOREIGN KEY ([IDUtente]) REFERENCES [dbo].[Utenti] ([ID])
);




GO



GO
CREATE NONCLUSTERED INDEX [IX_IDGruppoUtenti]
    ON [dbo].[UtentiGruppiUtenti]([IDGruppoUtenti] ASC)
    INCLUDE([IDUtente]) WITH (FILLFACTOR = 90);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_IDUtente]
    ON [dbo].[UtentiGruppiUtenti]([IDUtente] ASC, [IDGruppoUtenti] ASC) WITH (FILLFACTOR = 70);

