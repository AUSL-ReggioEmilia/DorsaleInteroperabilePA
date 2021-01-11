CREATE TABLE [dbo].[PazientiQueueSemaforo] (
    [HostBiztalk]      VARCHAR (64) NOT NULL,
    [DataLettura]      DATETIME     NOT NULL,
    [Primario]         BIT          CONSTRAINT [DF_PazientiQueueSemaforo_Primario] DEFAULT ((0)) NOT NULL,
    [ContatoreLetture] INT          CONSTRAINT [DF_PazientiQueueSemaforo_ContatoreLetture] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PazientiQueueSemaforo] PRIMARY KEY CLUSTERED ([HostBiztalk] ASC)
);

