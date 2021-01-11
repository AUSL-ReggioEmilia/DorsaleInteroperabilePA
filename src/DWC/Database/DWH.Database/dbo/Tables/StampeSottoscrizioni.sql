CREATE TABLE [dbo].[StampeSottoscrizioni] (
    [Id]                  UNIQUEIDENTIFIER CONSTRAINT [DF_StampeSottoscrizioni_ID] DEFAULT (newid()) NOT NULL,
    [DataInserimento]     DATETIME         CONSTRAINT [DF_StampeSottoscrizioni_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]        DATETIME         CONSTRAINT [DF_StampeSottoscrizioni_DataModifica] DEFAULT (getdate()) NOT NULL,
    [Account]             VARCHAR (128)    NOT NULL,
    [DataInizio]          DATETIME         NOT NULL,
    [DataFine]            DATETIME         NOT NULL,
    [TipoReferti]         INT              CONSTRAINT [DF_StampeSottoscrizioni_TipoReferti] DEFAULT ((0)) NOT NULL,
    [ServerDiStampa]      VARCHAR (64)     NULL,
    [Stampante]           VARCHAR (64)     NULL,
    [Stato]               INT              NOT NULL,
    [TipoSottoscrizione]  INT              CONSTRAINT [DF_StampeSottoscrizioni_TipoSottoscrizione] DEFAULT ((0)) NOT NULL,
    [Nome]                VARCHAR (128)    CONSTRAINT [DF_StampeSottoscrizioni_Nome] DEFAULT ('') NOT NULL,
    [Descrizione]         VARCHAR (1024)   NULL,
    [Ts]                  ROWVERSION       NOT NULL,
    [StampaConfidenziali] BIT              CONSTRAINT [DF_StampeSottoscrizioni_StampaConfidenziali] DEFAULT ((0)) NOT NULL,
    [StampaOscurati]      BIT              CONSTRAINT [DF_StampeSottoscrizioni_StampaOscurati] DEFAULT ((0)) NOT NULL,
    [NumeroCopie]         TINYINT          CONSTRAINT [DF_StampeSottoscrizioni_NumeroCopie] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_StampeSottoscrizioni] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);




GO
CREATE NONCLUSTERED INDEX [IX_StampeSottoscrizioni]
    ON [dbo].[StampeSottoscrizioni]([Account] ASC, [DataInizio] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_StampeSottoscrizioni_Stato]
    ON [dbo].[StampeSottoscrizioni]([Stato] ASC, [DataInizio] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_StampeSottoscrizioni_ServerDiStampa_Stampante]
    ON [dbo].[StampeSottoscrizioni]([ServerDiStampa] ASC, [Stampante] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_StampeSottoscrizioni_Nome]
    ON [dbo].[StampeSottoscrizioni]([Nome] ASC) WITH (FILLFACTOR = 95);

