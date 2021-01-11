CREATE TABLE [dbo].[CodaNoteAnamnesticheOutputSemaforo] (
    [HostBiztalk]      VARCHAR (64) NOT NULL,
    [DataLettura]      DATETIME     NOT NULL,
    [Primario]         BIT          CONSTRAINT [DF_CodaNoteAnamnesticheOutputSemaforo_Primario] DEFAULT ((0)) NOT NULL,
    [ContatoreLetture] INT          CONSTRAINT [DF_CodaNoteAnamnesticheOutputSemaforo_ContatoreLetture] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CodaNoteAnamnesticheOutputSemaforo] PRIMARY KEY CLUSTERED ([HostBiztalk] ASC)
);

