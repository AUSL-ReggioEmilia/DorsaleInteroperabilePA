CREATE TABLE [dbo].[CodaRichiesteOutputSemaforo] (
    [HostBiztalk]      VARCHAR (64) NOT NULL,
    [DataLettura]      DATETIME     NOT NULL,
    [Primario]         BIT          CONSTRAINT [DF_CodaRichiesteOutputSemaforo_Primario] DEFAULT ((0)) NOT NULL,
    [ContatoreLetture] INT          CONSTRAINT [DF_CodaRichiesteOutputSemaforo_ContatoreLetture] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CodaRichiesteOutputSemaforo] PRIMARY KEY CLUSTERED ([HostBiztalk] ASC)
);

