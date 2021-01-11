CREATE TABLE [dbo].[CodaRefertiOutputInviati] (
    [Id]                  UNIQUEIDENTIFIER CONSTRAINT [DF_CodaRefertiOutputInviati_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataInvio]           DATETIME         CONSTRAINT [DF_CodaRefertiOutputInviati_DataInvio] DEFAULT (getutcdate()) NOT NULL,
    [IdSequenza]          INT              NOT NULL,
    [DataInserimento]     DATETIME         NOT NULL,
    [IdReferto]           UNIQUEIDENTIFIER NOT NULL,
    [Operazione]          SMALLINT         NOT NULL,
    [IdCorrelazione]      VARCHAR (64)     NOT NULL,
    [CorrelazioneTimeout] INT              NOT NULL,
    [OrdineInvio]         SMALLINT         NOT NULL,
    [Messaggio]           XML              NULL,
    [MessaggioCompresso]  VARBINARY (MAX)  NULL,
    CONSTRAINT [PK_CodaRefertiOutputInviati_Id] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);




GO
CREATE NONCLUSTERED INDEX [IX_CodaRefertiOutputInviati_IdReferto]
    ON [dbo].[CodaRefertiOutputInviati]([IdReferto] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_CodaRefertiOutputInviati_DataInvio]
    ON [dbo].[CodaRefertiOutputInviati]([DataInvio] ASC, [DataInserimento] ASC)
    INCLUDE([IdReferto], [Operazione]);



