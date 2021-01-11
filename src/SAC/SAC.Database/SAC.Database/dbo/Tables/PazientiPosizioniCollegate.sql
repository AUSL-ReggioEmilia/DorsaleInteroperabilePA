CREATE TABLE [dbo].[PazientiPosizioniCollegate] (
    [IdPosizioneCollegata]    VARCHAR (16)     NOT NULL,
    [IdSacPosizioneCollegata] UNIQUEIDENTIFIER NOT NULL,
    [IdSacOriginale]          UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]         DATETIME         CONSTRAINT [DF_PosizioniCollegate_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [Utente]                  VARCHAR (64)     NOT NULL,
    [Note]                    VARCHAR (2048)   NULL,
    CONSTRAINT [PK_PazientiPosizioniCollegate] PRIMARY KEY CLUSTERED ([IdPosizioneCollegata] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_PazientiPosizioniCollegate_Pazienti_IdSacOriginale] FOREIGN KEY ([IdSacOriginale]) REFERENCES [dbo].[Pazienti] ([Id]),
    CONSTRAINT [FK_PazientiPosizioniCollegate_Pazienti_IdSacPosizioneCollegata] FOREIGN KEY ([IdSacPosizioneCollegata]) REFERENCES [dbo].[Pazienti] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiPosizioniCollegate_IdSacOriginale]
    ON [dbo].[PazientiPosizioniCollegate]([IdSacOriginale] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiPosizioniCollegate_IdSacPosizioneCollegata]
    ON [dbo].[PazientiPosizioniCollegate]([IdSacPosizioneCollegata] ASC) WITH (FILLFACTOR = 70);

