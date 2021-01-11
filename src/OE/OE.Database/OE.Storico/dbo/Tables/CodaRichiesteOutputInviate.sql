CREATE TABLE [dbo].[CodaRichiesteOutputInviate] (
    [Id]                  UNIQUEIDENTIFIER NOT NULL,
    [DataInvio]           DATETIME         NOT NULL,
    [IdSequenza]          INT              NOT NULL,
    [DataInserimento]     DATETIME         NOT NULL,
    [IdTicketInserimento] UNIQUEIDENTIFIER NOT NULL,
    [IdOrdineTestata]     UNIQUEIDENTIFIER NOT NULL,
    [Messaggio]           XML              NOT NULL,
    CONSTRAINT [PK_CodaRichiesteOutputInviate] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70)
);

