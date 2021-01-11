CREATE TABLE [dbo].[CodaPrescrizioniOutput] (
    [IdSequenza]          INT              IDENTITY (1, 1) NOT NULL,
    [DataInserimento]     DATETIME         CONSTRAINT [DF_CodaPrescrizioniOutput_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [IdPrescrizione]      UNIQUEIDENTIFIER NOT NULL,
    [Operazione]          SMALLINT         NOT NULL,
    [IdCorrelazione]      VARCHAR (64)     NOT NULL,
    [CorrelazioneTimeout] INT              NOT NULL,
    [OrdineInvio]         SMALLINT         NOT NULL,
    [Messaggio]           XML              NOT NULL,
    CONSTRAINT [PK_CodaPrescrizioniOutput_Id] PRIMARY KEY CLUSTERED ([IdSequenza] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [IX_OrdineInvio_IdSequenza]
    ON [dbo].[CodaPrescrizioniOutput]([OrdineInvio] ASC, [IdSequenza] ASC) WITH (FILLFACTOR = 95);

