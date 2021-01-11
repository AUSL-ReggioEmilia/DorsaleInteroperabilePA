CREATE TABLE [dbo].[CodaRefertiOutputSemaforo] (
    [HostBiztalk]      VARCHAR (64) NOT NULL,
    [DataLettura]      DATETIME     NOT NULL,
    [Primario]         BIT          CONSTRAINT [DF_CodaRefertiOutputSemaforo_Primario] DEFAULT ((0)) NOT NULL,
    [ContatoreLetture] INT          CONSTRAINT [DF_CodaRefertiOutputSemaforo_ContatoreLetture] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CodaRefertiOutputSemaforo] PRIMARY KEY CLUSTERED ([HostBiztalk] ASC)
);

