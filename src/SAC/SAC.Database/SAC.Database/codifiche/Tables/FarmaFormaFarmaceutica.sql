CREATE TABLE [codifiche].[FarmaFormaFarmaceutica] (
    [Id]               UNIQUEIDENTIFIER CONSTRAINT [DF_FarmaFormaFarmaceutica_guid] DEFAULT (newsequentialid()) NOT NULL,
    [Codice]           VARCHAR (16)     NOT NULL,
    [Descrizione]      VARCHAR (256)    NULL,
    [DescizioneEstesa] VARCHAR (256)    NULL,
    [Attivo]           BIT              NOT NULL,
    CONSTRAINT [PK_FarmaFormaFarmaceutica] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO
CREATE CLUSTERED INDEX [IX_Codice]
    ON [codifiche].[FarmaFormaFarmaceutica]([Codice] ASC);

