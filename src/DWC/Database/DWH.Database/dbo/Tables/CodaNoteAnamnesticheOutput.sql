CREATE TABLE [dbo].[CodaNoteAnamnesticheOutput] (
    [IdSequenza]          INT              IDENTITY (1, 1) NOT NULL,
    [DataInserimento]     DATETIME         CONSTRAINT [DF_CodaNoteAnamnesticheOutput_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [IdNotaAnamnestica]   UNIQUEIDENTIFIER NOT NULL,
    [Operazione]          SMALLINT         NOT NULL,
    [IdCorrelazione]      VARCHAR (64)     NOT NULL,
    [CorrelazioneTimeout] INT              NOT NULL,
    [OrdineInvio]         SMALLINT         NOT NULL,
    [Messaggio]           XML              NOT NULL,
    CONSTRAINT [PK_CodaNoteAnamnesticheOutput_Id] PRIMARY KEY CLUSTERED ([IdSequenza] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_OrdineInvio_IdSequenza]
    ON [dbo].[CodaNoteAnamnesticheOutput]([OrdineInvio] ASC, [IdSequenza] ASC) WITH (FILLFACTOR = 80);

