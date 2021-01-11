CREATE TABLE [dbo].[CodaEventiOutputSemaforo] (
    [HostBiztalk]      VARCHAR (64) NOT NULL,
    [DataLettura]      DATETIME     NOT NULL,
    [Primario]         BIT          CONSTRAINT [DF_CodaEventiOutputSemaforo_Primario] DEFAULT ((0)) NOT NULL,
    [ContatoreLetture] INT          CONSTRAINT [DF_CodaEventiOutputSemaforo_ContatoreLetture] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CodaEventiOutputSemaforo] PRIMARY KEY CLUSTERED ([HostBiztalk] ASC)
);

