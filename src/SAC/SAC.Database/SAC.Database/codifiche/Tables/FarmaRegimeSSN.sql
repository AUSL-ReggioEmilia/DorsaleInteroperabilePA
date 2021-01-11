CREATE TABLE [codifiche].[FarmaRegimeSSN] (
    [Id]                  UNIQUEIDENTIFIER CONSTRAINT [DF_FarmaRegimeSSN_Id] DEFAULT (newsequentialid()) NOT NULL,
    [Codice]              VARCHAR (16)     NOT NULL,
    [Descrizione]         VARCHAR (256)    NULL,
    [DescizioneEstesa]    VARCHAR (256)    NULL,
    [Attivo]              BIT              NOT NULL,
    [AbbreviazioneRegime] CHAR (3)         NULL,
    [PercentualeTicket]   TINYINT          NULL,
    [Concedibilita]       BIT              NULL,
    CONSTRAINT [PK_FarmaRegimeSSN] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO
CREATE CLUSTERED INDEX [IX_Codice]
    ON [codifiche].[FarmaRegimeSSN]([Codice] ASC);

