CREATE TABLE [dbo].[RicercaOrdiniProcessoLog] (
    [Id]                    INT              IDENTITY (1, 1) NOT NULL,
    [IdOrdineTestata]       UNIQUEIDENTIFIER NOT NULL,
    [DataProcessoUtc]       DATETIME2 (7)    CONSTRAINT [DF_RicercaOrdiniProcessoLog_DataProcessoUtc] DEFAULT (getutcdate()) NOT NULL,
    [XmlOrdine]             XML              NULL,
    [XmlDatePianificazione] XML              NULL,
    CONSTRAINT [PK_RicercaOrdiniProcessoLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70)
);

