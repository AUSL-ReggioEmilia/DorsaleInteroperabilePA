CREATE TABLE [dbo].[OrdiniErogatiTestateDatiAggiuntivi] (
    [ID]                     UNIQUEIDENTIFIER CONSTRAINT [DF_OrdiniErogatiTestateDatiAggiuntivi_ID] DEFAULT (newid()) NOT NULL,
    [DataInserimento]        DATETIME2 (0)    CONSTRAINT [DF_OrdiniErogatiTestateDatiAggiuntivi_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]           DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento]    UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]       UNIQUEIDENTIFIER NOT NULL,
    [TS]                     ROWVERSION       NOT NULL,
    [IDOrdineErogatoTestata] UNIQUEIDENTIFIER NOT NULL,
    [IDDatoAggiuntivo]       VARCHAR (64)     NULL,
    [Nome]                   VARCHAR (128)    NOT NULL,
    [TipoDato]               VARCHAR (32)     NOT NULL,
    [TipoContenuto]          VARCHAR (32)     NULL,
    [ValoreDato]             SQL_VARIANT      NULL,
    [ValoreDatoVarchar]      VARCHAR (MAX)    NULL,
    [ValoreDatoXml]          XML              NULL,
    [ParametroSpecifico]     BIT              NULL,
    [Persistente]            BIT              NULL,
    CONSTRAINT [PK_OrdiniErogatiTestateDatiAggiuntivi] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_OrdiniErogatiTestateDatiAggiuntivi_OrdiniErogatiTestate] FOREIGN KEY ([IDOrdineErogatoTestata]) REFERENCES [dbo].[OrdiniErogatiTestate] ([ID]),
    CONSTRAINT [FK_OrdiniErogatiTestateDatiAggiuntivi_Tickets_Inserimento] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID]),
    CONSTRAINT [FK_OrdiniErogatiTestateDatiAggiuntivi_Tickets_Modifica] FOREIGN KEY ([IDTicketModifica]) REFERENCES [dbo].[Tickets] ([ID])
);






GO
CREATE CLUSTERED INDEX [IXC_IdOrdineErogatoTestata]
    ON [dbo].[OrdiniErogatiTestateDatiAggiuntivi]([IDOrdineErogatoTestata] ASC, [IDDatoAggiuntivo] ASC) WITH (FILLFACTOR = 70, DATA_COMPRESSION = PAGE);




GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[OrdiniErogatiTestateDatiAggiuntivi]([IDTicketModifica] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[OrdiniErogatiTestateDatiAggiuntivi]([IDTicketInserimento] ASC);

