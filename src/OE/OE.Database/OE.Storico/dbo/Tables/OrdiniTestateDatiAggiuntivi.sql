CREATE TABLE [dbo].[OrdiniTestateDatiAggiuntivi] (
    [ID]                  UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]     DATETIME2 (3)    NOT NULL,
    [DataModifica]        DATETIME2 (3)    NOT NULL,
    [IDTicketInserimento] UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]    UNIQUEIDENTIFIER NOT NULL,
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
    CONSTRAINT [PK_OrdiniTestateDatiAggiuntivi] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);




GO
CREATE CLUSTERED INDEX [IXC_IDOrdineTestata]
    ON [dbo].[OrdiniTestateDatiAggiuntivi]([IDOrdineTestata] ASC, [IDDatoAggiuntivo] ASC, [Nome] ASC) WITH (FILLFACTOR = 70, DATA_COMPRESSION = PAGE);

