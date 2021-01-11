CREATE TABLE [dbo].[CodaNoteAnamnesticheOutputInviati] (
    [Id]                  UNIQUEIDENTIFIER CONSTRAINT [DF_CodaNoteAnamnesticheOutputInviati_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataInvio]           DATETIME         CONSTRAINT [DF_CodaNoteAnamnesticheOutputInviati_DataInvio] DEFAULT (getutcdate()) NOT NULL,
    [IdSequenza]          INT              NOT NULL,
    [DataInserimento]     DATETIME         NOT NULL,
    [IdNotaAnamnestica]   UNIQUEIDENTIFIER NOT NULL,
    [Operazione]          SMALLINT         NOT NULL,
    [IdCorrelazione]      VARCHAR (64)     NOT NULL,
    [CorrelazioneTimeout] INT              NOT NULL,
    [OrdineInvio]         SMALLINT         NOT NULL,
    [MessaggioCompresso]  VARBINARY (MAX)  NULL,
    CONSTRAINT [PK_CodaNoteAnamnesticheOutputInviati_Id] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [IX_IdNotaAnamnestica]
    ON [dbo].[CodaNoteAnamnesticheOutputInviati]([IdNotaAnamnestica] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_DataInvio]
    ON [dbo].[CodaNoteAnamnesticheOutputInviati]([DataInvio] ASC, [DataInserimento] ASC)
    INCLUDE([IdNotaAnamnestica], [Operazione]) WITH (FILLFACTOR = 80);

