CREATE TABLE [dbo].[LogMntAggancioPaziente] (
    [Id]               UNIQUEIDENTIFIER CONSTRAINT [DF_LogMntAggancioPaziente_Id] DEFAULT (newid()) NOT NULL,
    [Oggetto]          VARCHAR (64)     NOT NULL,
    [DataInserimento]  DATETIME         CONSTRAINT [DF_LogMntAggancioPaziente_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [IdPaziente]       UNIQUEIDENTIFIER NOT NULL,
    [AziendaErogante]  VARCHAR (16)     NOT NULL,
    [SistemaErogante]  VARCHAR (16)     NOT NULL,
    [IdOggetto]        UNIQUEIDENTIFIER NOT NULL,
    [IdEsternoOggetto] VARCHAR (64)     NOT NULL,
    CONSTRAINT [PK_LogMntAggancioPaziente] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [CK_LogMntAggancioPaziente_Oggetto] CHECK ([Oggetto]='Referto' OR [Oggetto]='Ricovero' OR [Oggetto]='Prenotazione' OR [Oggetto]='Prescrizione' OR [Oggetto]='NotaAnamnestica')
);


GO
CREATE NONCLUSTERED INDEX [IX_LogMntAggancioPaziente_Oggetto]
    ON [dbo].[LogMntAggancioPaziente]([Oggetto] ASC, [DataInserimento] ASC) WITH (FILLFACTOR = 90);

