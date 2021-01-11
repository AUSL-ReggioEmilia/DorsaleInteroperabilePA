CREATE TABLE [dbo].[EntitaAccessiServizi] (
    [Id]                          INT              IDENTITY (1, 1) NOT NULL,
    [IdServizio]                  TINYINT          NOT NULL,
    [IdEntitaAccesso]             UNIQUEIDENTIFIER NOT NULL,
    [Creazione]                   BIT              CONSTRAINT [DF_EntitaAccessiServizi_Creazione] DEFAULT ((0)) NOT NULL,
    [Lettura]                     BIT              CONSTRAINT [DF_EntitaAccessiServizi_Lettura] DEFAULT ((0)) NOT NULL,
    [Scrittura]                   BIT              CONSTRAINT [DF_EntitaAccessiServizi_Scrittura] DEFAULT ((0)) NOT NULL,
    [Eliminazione]                BIT              CONSTRAINT [DF_EntitaAccessiServizi_Eliminazione] DEFAULT ((0)) NOT NULL,
    [ControlloCompleto]           BIT              CONSTRAINT [DF_EntitaAccessiServizi_ControlloCompleto] DEFAULT ((0)) NOT NULL,
    [CreazioneAnonimizzazione]    BIT              CONSTRAINT [DF_EntitaAccessiServizi_CreazioneAnonimizzazione] DEFAULT ((0)) NOT NULL,
    [LetturaAnonimizzazione]      BIT              CONSTRAINT [DF_EntitaAccessiServizi_LetturaAnonimizzazione] DEFAULT ((0)) NOT NULL,
    [CreazionePosizioneCollegata] BIT              CONSTRAINT [DF_EntitaAccessiServizi_CreazionePosizioneCollegata] DEFAULT ((0)) NOT NULL,
    [LetturaPosizioneCollegata]   BIT              CONSTRAINT [DF_EntitaAccessiServizi_LetturaPosizioneCollegata] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_EntitaAccessiServizi] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_EntitaAccessiServizi_EntitaAccessi] FOREIGN KEY ([IdEntitaAccesso]) REFERENCES [dbo].[EntitaAccessi] ([Id]),
    CONSTRAINT [FK_EntitaAccessiServizi_Servizi] FOREIGN KEY ([IdServizio]) REFERENCES [dbo].[Servizi] ([Id])
);



