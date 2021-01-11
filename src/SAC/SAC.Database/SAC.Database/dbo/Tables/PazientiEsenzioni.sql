CREATE TABLE [dbo].[PazientiEsenzioni] (
    [Id]                            UNIQUEIDENTIFIER CONSTRAINT [DF_PazientiEsenzioni_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [IdPaziente]                    UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]               DATETIME         NOT NULL,
    [DataModifica]                  DATETIME         NOT NULL,
    [Ts]                            ROWVERSION       NOT NULL,
    [CodiceEsenzione]               VARCHAR (32)     NULL,
    [CodiceDiagnosi]                VARCHAR (32)     NULL,
    [Patologica]                    BIT              NULL,
    [DataInizioValidita]            DATETIME         NULL,
    [DataFineValidita]              DATETIME         NULL,
    [NumeroAutorizzazioneEsenzione] VARCHAR (64)     NULL,
    [NoteAggiuntive]                VARCHAR (2048)   NULL,
    [CodiceTestoEsenzione]          VARCHAR (64)     NULL,
    [TestoEsenzione]                VARCHAR (2048)   NULL,
    [DecodificaEsenzioneDiagnosi]   VARCHAR (1024)   NULL,
    [AttributoEsenzioneDiagnosi]    VARCHAR (1024)   NULL,
    [Provenienza]                   VARCHAR (16)     CONSTRAINT [DF_PazientiEsenzioni_Provenienza] DEFAULT ('LHA') NOT NULL,
    [OperatoreId]                   VARCHAR (64)     NULL,
    [OperatoreCognome]              VARCHAR (64)     NULL,
    [OperatoreNome]                 VARCHAR (64)     NULL,
    [OperatoreComputer]             VARCHAR (64)     NULL,
    CONSTRAINT [PK_PazientiEsenzioni] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_PazientiEsenzioni_Pazienti] FOREIGN KEY ([IdPaziente]) REFERENCES [dbo].[Pazienti] ([Id]),
    CONSTRAINT [FK_PazientiEsenzioni_Provenienze] FOREIGN KEY ([Provenienza]) REFERENCES [dbo].[Provenienze] ([Provenienza])
);




GO
CREATE CLUSTERED INDEX [IX_PazientiEsenzioni_IdPaziente]
    ON [dbo].[PazientiEsenzioni]([IdPaziente] ASC, [DataInizioValidita] ASC, [DataFineValidita] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiEsenzioni_Provenienza]
    ON [dbo].[PazientiEsenzioni]([Provenienza] ASC) WITH (FILLFACTOR = 60);

