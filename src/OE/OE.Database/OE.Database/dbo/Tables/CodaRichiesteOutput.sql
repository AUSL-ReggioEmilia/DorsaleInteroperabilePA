CREATE TABLE [dbo].[CodaRichiesteOutput] (
    [IdSequenza]          INT              IDENTITY (1, 1) NOT NULL,
    [DataInserimento]     DATETIME         CONSTRAINT [DF_CodaRichiesteOutput_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [IdTicketInserimento] UNIQUEIDENTIFIER NOT NULL,
    [IdOrdineTestata]     UNIQUEIDENTIFIER NOT NULL,
    [Messaggio]           XML              NOT NULL,
    CONSTRAINT [PK_CodaRichiesteOutput] PRIMARY KEY CLUSTERED ([IdSequenza] ASC) WITH (FILLFACTOR = 70)
);



