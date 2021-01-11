CREATE TABLE [dbo].[CodaPrescrizioniOutputSemaforo] (
    [HostBiztalk]      VARCHAR (64) NOT NULL,
    [DataLettura]      DATETIME     NOT NULL,
    [Primario]         BIT          CONSTRAINT [DF_CodaPrescrizioniOutputSemaforo_Primario] DEFAULT ((0)) NOT NULL,
    [ContatoreLetture] INT          CONSTRAINT [DF_CodaPrescrizioniOutputSemaforo_ContatoreLetture] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CodaPrescrizioniOutputSemaforo] PRIMARY KEY CLUSTERED ([HostBiztalk] ASC)
);

