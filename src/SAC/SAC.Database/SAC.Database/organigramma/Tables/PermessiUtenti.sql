CREATE TABLE [organigramma].[PermessiUtenti] (
    [Id]            UNIQUEIDENTIFIER CONSTRAINT [DF_PermessiUtenti_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [Utente]        VARCHAR (64)     NOT NULL,
    [Lettura]       BIT              CONSTRAINT [DF_PermessiUtenti_Lettura] DEFAULT ((0)) NOT NULL,
    [Scrittura]     BIT              CONSTRAINT [DF_PermessiUtenti_Scrittura] DEFAULT ((0)) NOT NULL,
    [Cancellazione] BIT              CONSTRAINT [DF_PermessiUtenti_Cancellazione] DEFAULT ((0)) NOT NULL,
    [Disattivato]   TINYINT          CONSTRAINT [DF_PazientiUtenti_Disattivato] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PazientiUtenti] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_PazientiUtenti_Utenti] FOREIGN KEY ([Utente]) REFERENCES [dbo].[Utenti] ([Utente])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Utente]
    ON [organigramma].[PermessiUtenti]([Utente] ASC) WITH (FILLFACTOR = 95);

