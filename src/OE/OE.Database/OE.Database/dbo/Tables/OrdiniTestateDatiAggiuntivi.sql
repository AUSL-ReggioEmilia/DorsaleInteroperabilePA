CREATE TABLE [dbo].[OrdiniTestateDatiAggiuntivi] (
    [ID]                  UNIQUEIDENTIFIER CONSTRAINT [DF_OrdiniTestateDatiAggiuntivi_ID] DEFAULT (newid()) NOT NULL,
    [DataInserimento]     DATETIME2 (0)    CONSTRAINT [DF_OrdiniTestateDatiAggiuntivi_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]        DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento] UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]    UNIQUEIDENTIFIER NOT NULL,
    [TS]                  ROWVERSION       NOT NULL,
    [IDOrdineTestata]     UNIQUEIDENTIFIER NOT NULL,
    [IDDatoAggiuntivo]    VARCHAR (64)     NULL,
    [Nome]                VARCHAR (128)    NOT NULL,
    [TipoDato]            VARCHAR (32)     NOT NULL,
    [TipoContenuto]       VARCHAR (32)     NULL,
    [ValoreDato]          SQL_VARIANT      NULL,
    [ValoreDatoVarchar]   VARCHAR (MAX)    NULL,
    [ValoreDatoXml]       XML              NULL,
    [ParametroSpecifico]  BIT              NULL,
    [Persistente]         BIT              NULL,
    CONSTRAINT [PK_OrdiniTestateDatiAggiuntivi] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_OrdiniTestateDatiAggiuntivi_OrdiniTestate] FOREIGN KEY ([IDOrdineTestata]) REFERENCES [dbo].[OrdiniTestate] ([ID]),
    CONSTRAINT [FK_OrdiniTestateDatiAggiuntivi_Tickets_Inserimento] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID]),
    CONSTRAINT [FK_OrdiniTestateDatiAggiuntivi_Tickets_Modifica] FOREIGN KEY ([IDTicketModifica]) REFERENCES [dbo].[Tickets] ([ID])
);






GO
CREATE UNIQUE CLUSTERED INDEX [IXC_DataInserimento]
    ON [dbo].[OrdiniTestateDatiAggiuntivi]([DataInserimento] ASC, [ID] ASC) WITH (FILLFACTOR = 70, DATA_COMPRESSION = PAGE);




GO
CREATE NONCLUSTERED INDEX [IX_IDOrdineTestata]
    ON [dbo].[OrdiniTestateDatiAggiuntivi]([IDOrdineTestata] ASC, [IDDatoAggiuntivo] ASC, [Nome] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[OrdiniTestateDatiAggiuntivi]([IDTicketModifica] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[OrdiniTestateDatiAggiuntivi]([IDTicketInserimento] ASC);

