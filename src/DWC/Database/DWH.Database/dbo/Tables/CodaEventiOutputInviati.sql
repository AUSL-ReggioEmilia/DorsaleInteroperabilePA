CREATE TABLE [dbo].[CodaEventiOutputInviati] (
    [Id]                  UNIQUEIDENTIFIER CONSTRAINT [DF_CodaEventiOutputInviati_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataInvio]           DATETIME         CONSTRAINT [DF_CodaEventiOutputInviati_DataInvio] DEFAULT (getutcdate()) NOT NULL,
    [IdSequenza]          INT              NOT NULL,
    [DataInserimento]     DATETIME         NOT NULL,
    [IdEvento]            UNIQUEIDENTIFIER NOT NULL,
    [Operazione]          SMALLINT         NOT NULL,
    [IdCorrelazione]      VARCHAR (64)     NOT NULL,
    [CorrelazioneTimeout] INT              NOT NULL,
    [OrdineInvio]         SMALLINT         NOT NULL,
    [Messaggio]           XML              NULL,
    [MessaggioCompresso]  VARBINARY (MAX)  NULL,
    CONSTRAINT [PK_CodaEventiOutputInviati_Id] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);




GO
CREATE NONCLUSTERED INDEX [IX_CodaEventiOutputInviati_IdEvento]
    ON [dbo].[CodaEventiOutputInviati]([IdEvento] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_CodaEventiOutputInviati_DataInvio]
    ON [dbo].[CodaEventiOutputInviati]([DataInvio] ASC, [DataInserimento] ASC)
    INCLUDE([IdEvento], [Operazione]);



