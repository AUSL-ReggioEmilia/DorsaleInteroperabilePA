CREATE TABLE [dbo].[ConsensiQueueSemaforo] (
    [HostBiztalk]      VARCHAR (64) NOT NULL,
    [DataLettura]      DATETIME     NOT NULL,
    [Primario]         BIT          CONSTRAINT [DF_ConsensiQueueSemaforo_Primario] DEFAULT ((0)) NOT NULL,
    [ContatoreLetture] INT          CONSTRAINT [DF_ConsensiQueueSemaforo_ContatoreLetture] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ConsensiQueueSemaforo] PRIMARY KEY CLUSTERED ([HostBiztalk] ASC)
);

