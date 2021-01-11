CREATE TABLE [dbo].[PazientiNotificheUtentiSemaforo] (
    [HostBiztalk]      VARCHAR (64) NOT NULL,
    [DataLettura]      DATETIME     NOT NULL,
    [Primario]         BIT          CONSTRAINT [DF_PazientiNotificheUtentiSemaforo_Primario] DEFAULT ((0)) NOT NULL,
    [ContatoreLetture] INT          CONSTRAINT [DF_PazientiNotificheUtentiSemaforo_ContatoreLetture] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PazientiNotificheUtentiSemaforo] PRIMARY KEY CLUSTERED ([HostBiztalk] ASC)
);

