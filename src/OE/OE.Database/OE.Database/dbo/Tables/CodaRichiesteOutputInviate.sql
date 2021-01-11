CREATE TABLE [dbo].[CodaRichiesteOutputInviate] (
    [Id]                  UNIQUEIDENTIFIER CONSTRAINT [DF_CodaRichiesteOutputInviate_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataInvio]           DATETIME         CONSTRAINT [DF_CodaRichiesteOutputInviate_DataInvio] DEFAULT (getdate()) NOT NULL,
    [IdSequenza]          INT              NOT NULL,
    [DataInserimento]     DATETIME         NOT NULL,
    [IdTicketInserimento] UNIQUEIDENTIFIER NOT NULL,
    [IdOrdineTestata]     UNIQUEIDENTIFIER NOT NULL,
    [Messaggio]           XML              NOT NULL,
    CONSTRAINT [PK_CodaRichiesteOutputInviate] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70)
);




GO
CREATE NONCLUSTERED INDEX [IX_DataInvio]
    ON [dbo].[CodaRichiesteOutputInviate]([DataInvio] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 70);

