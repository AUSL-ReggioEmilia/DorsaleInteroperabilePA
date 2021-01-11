CREATE TABLE [dbo].[CodaRefertiOutput] (
    [IdSequenza]          INT              IDENTITY (1, 1) NOT NULL,
    [DataInserimento]     DATETIME         CONSTRAINT [DF_CodaRefertiOutput_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [IdReferto]           UNIQUEIDENTIFIER NOT NULL,
    [Operazione]          SMALLINT         NOT NULL,
    [IdCorrelazione]      VARCHAR (64)     NOT NULL,
    [CorrelazioneTimeout] INT              NOT NULL,
    [OrdineInvio]         SMALLINT         NOT NULL,
    [Messaggio]           XML              NULL,
    CONSTRAINT [PK_CodaRefertiOutput_Id] PRIMARY KEY CLUSTERED ([IdSequenza] ASC) WITH (FILLFACTOR = 95)
);






GO
CREATE NONCLUSTERED INDEX [IX_CodaRefertiOutput_OrdineInvio_IdSequenza]
    ON [dbo].[CodaRefertiOutput]([OrdineInvio] ASC, [IdSequenza] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IdReferto]
    ON [dbo].[CodaRefertiOutput]([IdReferto] ASC);

