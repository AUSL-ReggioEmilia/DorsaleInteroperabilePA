CREATE TABLE [dbo].[ConsensiNotificheUtentiSemaforo] (
    [HostBiztalk]      VARCHAR (64) NOT NULL,
    [DataLettura]      DATETIME     NOT NULL,
    [Primario]         BIT          CONSTRAINT [DF_ConsensiNotificheUtentiSemaforo_Primario] DEFAULT ((0)) NOT NULL,
    [ContatoreLetture] INT          CONSTRAINT [DF_ConsensiNotificheUtentiSemaforo_ContatoreLetture] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ConsensiNotificheUtentiSemaforo] PRIMARY KEY CLUSTERED ([HostBiztalk] ASC)
);

