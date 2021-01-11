CREATE TABLE [dbo].[OrdiniRigheErogateDatiAggiuntivi] (
    [ID]                  UNIQUEIDENTIFIER CONSTRAINT [DF_OrdiniRigheErogateDatiAggiuntivi_ID] DEFAULT (newid()) NOT NULL,
    [DataInserimento]     DATETIME2 (0)    CONSTRAINT [DF_OrdiniRigheErogateDatiAggiuntivi_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]        DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento] UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]    UNIQUEIDENTIFIER NOT NULL,
    [TS]                  ROWVERSION       NOT NULL,
    [IDRigaErogata]       UNIQUEIDENTIFIER NOT NULL,
    [IDDatoAggiuntivo]    VARCHAR (64)     NULL,
    [Nome]                VARCHAR (128)    NOT NULL,
    [TipoDato]            VARCHAR (32)     NOT NULL,
    [TipoContenuto]       VARCHAR (32)     NULL,
    [ValoreDato]          SQL_VARIANT      NULL,
    [ValoreDatoVarchar]   VARCHAR (MAX)    NULL,
    [ValoreDatoXml]       XML              NULL,
    [ParametroSpecifico]  BIT              NULL,
    [Persistente]         BIT              NULL,
    CONSTRAINT [PK_OrdiniRigheErogateDatiAggiuntivi] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_OrdiniRigheErogateDatiAggiuntivi_OrdiniRigheErogate] FOREIGN KEY ([IDRigaErogata]) REFERENCES [dbo].[OrdiniRigheErogate] ([ID]),
    CONSTRAINT [FK_OrdiniRigheErogateDatiAggiuntivi_Tickets_Inserimento] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID]),
    CONSTRAINT [FK_OrdiniRigheErogateDatiAggiuntivi_Tickets_Modifica] FOREIGN KEY ([IDTicketModifica]) REFERENCES [dbo].[Tickets] ([ID])
);






GO
CREATE CLUSTERED INDEX [IXC_DataInserimento]
    ON [dbo].[OrdiniRigheErogateDatiAggiuntivi]([DataInserimento] ASC, [ID] ASC) WITH (FILLFACTOR = 70, DATA_COMPRESSION = PAGE);




GO
CREATE NONCLUSTERED INDEX [IX_IDRigaErogata_IDDato]
    ON [dbo].[OrdiniRigheErogateDatiAggiuntivi]([IDRigaErogata] ASC, [IDDatoAggiuntivo] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IDRigaErogata_Nome]
    ON [dbo].[OrdiniRigheErogateDatiAggiuntivi]([IDRigaErogata] ASC, [Nome] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[OrdiniRigheErogateDatiAggiuntivi]([IDTicketModifica] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[OrdiniRigheErogateDatiAggiuntivi]([IDTicketInserimento] ASC);

