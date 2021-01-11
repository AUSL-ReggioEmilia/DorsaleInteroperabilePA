CREATE TABLE [codifiche].[FarmaNotePrescrizione] (
    [Id]               UNIQUEIDENTIFIER CONSTRAINT [DF_FarmaNotePrescrizione_Id] DEFAULT (newsequentialid()) NOT NULL,
    [Codice]           VARCHAR (16)     NOT NULL,
    [Descrizione]      VARCHAR (256)    NULL,
    [DescizioneEstesa] VARCHAR (300)    NULL,
    [Attivo]           BIT              NOT NULL,
    [NotaRegristroUSL] BIT              NULL,
    [NumeroNota1]      CHAR (3)         NULL,
    [NumeroNota2]      CHAR (3)         NULL,
    CONSTRAINT [PK_FarmaNotePrescrizione] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO
CREATE CLUSTERED INDEX [IX_Codice]
    ON [codifiche].[FarmaNotePrescrizione]([Codice] ASC);

