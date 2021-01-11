CREATE TABLE [dbo].[EsenzioniUtenti] (
    [Id]                   UNIQUEIDENTIFIER CONSTRAINT [DF_EsenzioniUtenti_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [Utente]               VARCHAR (64)     NOT NULL,
    [Provenienza]          VARCHAR (16)     NOT NULL,
    [Lettura]              BIT              CONSTRAINT [DF_EsenzioniUtenti_Lettura] DEFAULT ((0)) NOT NULL,
    [Scrittura]            BIT              CONSTRAINT [DF_EsenzioniUtenti_Scrittura] DEFAULT ((0)) NOT NULL,
    [Cancellazione]        BIT              CONSTRAINT [DF_EsenzioniUtenti_Cancellazione] DEFAULT ((0)) NOT NULL,
    [LivelloAttendibilita] TINYINT          CONSTRAINT [DF_EsenzioniUtenti_LivelloAttendibilita] DEFAULT ((100)) NOT NULL,
    [Disattivato]          TINYINT          CONSTRAINT [DF_EsenzioniUtenti_Disattivato] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_EsenzioniUtenti] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_EsenzioniUtenti_Provenienze] FOREIGN KEY ([Provenienza]) REFERENCES [dbo].[Provenienze] ([Provenienza]),
    CONSTRAINT [FK_EsenzioniUtenti_Utenti] FOREIGN KEY ([Utente]) REFERENCES [dbo].[Utenti] ([Utente])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Utente]
    ON [dbo].[EsenzioniUtenti]([Utente] ASC) WITH (FILLFACTOR = 70);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Attivo; 1=Disattivato;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EsenzioniUtenti', @level2type = N'COLUMN', @level2name = N'Disattivato';

