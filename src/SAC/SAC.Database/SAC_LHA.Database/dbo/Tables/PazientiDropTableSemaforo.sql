CREATE TABLE [dbo].[PazientiDropTableSemaforo] (
    [HostBiztalk]      VARCHAR (64) NOT NULL,
    [DataLettura]      DATETIME     NOT NULL,
    [Primario]         BIT          CONSTRAINT [DF_PazientiDropTableSemaforo_Primario] DEFAULT ((0)) NOT NULL,
    [ContatoreLetture] INT          CONSTRAINT [DF_PazientiDropTableSemaforo_ContatoreLetture] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PazientiDropTableSemaforo] PRIMARY KEY CLUSTERED ([HostBiztalk] ASC)
);

