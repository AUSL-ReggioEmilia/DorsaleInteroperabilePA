CREATE TABLE [dbo].[CodaEventiOutput] (
    [IdSequenza]          INT              IDENTITY (1, 1) NOT NULL,
    [DataInserimento]     DATETIME         CONSTRAINT [DF_CodaEventiOutput_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [IdEvento]            UNIQUEIDENTIFIER NOT NULL,
    [Operazione]          SMALLINT         NOT NULL,
    [IdCorrelazione]      VARCHAR (64)     NOT NULL,
    [CorrelazioneTimeout] INT              NOT NULL,
    [OrdineInvio]         SMALLINT         NOT NULL,
    [Messaggio]           XML              NOT NULL,
    CONSTRAINT [PK_CodaEventiOutput_Id] PRIMARY KEY CLUSTERED ([IdSequenza] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [IX_CodaEventiOutput_OrdineInvio_IdSequenza]
    ON [dbo].[CodaEventiOutput]([OrdineInvio] ASC, [IdSequenza] ASC) WITH (FILLFACTOR = 95);

