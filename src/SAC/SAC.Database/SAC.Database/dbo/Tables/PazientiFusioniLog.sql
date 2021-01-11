CREATE TABLE [dbo].[PazientiFusioniLog] (
    [Id]                UNIQUEIDENTIFIER CONSTRAINT [DF_PazientiFusioniLog_Id] DEFAULT (newid()) NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_PazientiFusioniLog_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [Utente]            VARCHAR (64)     NOT NULL,
    [IdPaziente]        UNIQUEIDENTIFIER NOT NULL,
    [Provenienza]       VARCHAR (16)     NOT NULL,
    [IdProvenienza]     VARCHAR (64)     NOT NULL,
    [Cognome]           VARCHAR (64)     NULL,
    [Nome]              VARCHAR (64)     NULL,
    [DataNascita]       DATETIME         NULL,
    [CodiceFiscale]     VARCHAR (16)     NULL,
    [IdPazienteFuso]    UNIQUEIDENTIFIER NOT NULL,
    [ProvenienzaFuso]   VARCHAR (16)     NOT NULL,
    [IdProvenienzaFuso] VARCHAR (64)     NOT NULL,
    [CognomeFuso]       VARCHAR (64)     NULL,
    [NomeFuso]          VARCHAR (64)     NULL,
    [DataNascitaFuso]   DATETIME         NULL,
    [CodiceFiscaleFuso] VARCHAR (16)     NULL,
    [Motivo]            VARCHAR (4000)   NOT NULL,
    CONSTRAINT [PK_PazientiFusioniLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_PazientiFusioniLog_DataInserimento_ProvenienzaFuso_IdProvenienzaFuso]
    ON [dbo].[PazientiFusioniLog]([DataInserimento] ASC, [ProvenienzaFuso] ASC, [IdProvenienzaFuso] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiFusioniLog_DataInserimento_Provenienza_IdProvenienza]
    ON [dbo].[PazientiFusioniLog]([DataInserimento] ASC, [Provenienza] ASC, [IdProvenienza] ASC);

