CREATE TABLE [dbo].[StampeConfigurazioniStampa] (
    [Id]                         UNIQUEIDENTIFIER CONSTRAINT [DF_StampeConfigurazioniStampa_Id] DEFAULT (newid()) NOT NULL,
    [DataInserimento]            DATETIME         CONSTRAINT [DF_StampeConfigurazioniStampa_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModificaConfigurazione] DATETIME         CONSTRAINT [DF_StampeConfigurazioniStampa_DataModifica] DEFAULT (getdate()) NOT NULL,
    [AccountName]                VARCHAR (64)     NOT NULL,
    [ClientName]                 VARCHAR (64)     NOT NULL,
    [TipoConfigurazione]         INT              NOT NULL,
    [ServerDiStampa]             VARCHAR (64)     NOT NULL,
    [Stampante]                  VARCHAR (64)     NOT NULL,
    [DataTestStampante]          DATETIME         NULL,
    [ErroreTestStampante]        VARCHAR (2048)   NULL,
    CONSTRAINT [PK_StampeConfigurazioniStampa] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);




GO
CREATE NONCLUSTERED INDEX [IX_StampeConfigurazioniStampa]
    ON [dbo].[StampeConfigurazioniStampa]([AccountName] ASC, [ClientName] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=rete, 1=personale,2=locale', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StampeConfigurazioniStampa', @level2type = N'COLUMN', @level2name = N'TipoConfigurazione';

