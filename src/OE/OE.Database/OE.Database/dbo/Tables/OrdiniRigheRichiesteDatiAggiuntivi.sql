CREATE TABLE [dbo].[OrdiniRigheRichiesteDatiAggiuntivi] (
    [ID]                  UNIQUEIDENTIFIER CONSTRAINT [DF_OrdiniRigheRichiesteDatiAggiuntivi_ID] DEFAULT (newid()) NOT NULL,
    [DataInserimento]     DATETIME2 (0)    CONSTRAINT [DF_OrdiniRigheRichiesteDatiAggiuntivi_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]        DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento] UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]    UNIQUEIDENTIFIER NOT NULL,
    [TS]                  ROWVERSION       NOT NULL,
    [IDRigaRichiesta]     UNIQUEIDENTIFIER NOT NULL,
    [IDDatoAggiuntivo]    VARCHAR (64)     NULL,
    [Nome]                VARCHAR (128)    NOT NULL,
    [TipoDato]            VARCHAR (32)     NOT NULL,
    [TipoContenuto]       VARCHAR (32)     NULL,
    [ValoreDato]          SQL_VARIANT      NULL,
    [ValoreDatoVarchar]   VARCHAR (MAX)    NULL,
    [ValoreDatoXml]       XML              NULL,
    [ParametroSpecifico]  BIT              NULL,
    [Persistente]         BIT              NULL,
    CONSTRAINT [PK_OrdiniRigheRichiesteDatiAggiuntivi] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_OrdiniRigheRichiesteDatiAggiuntivi_OrdiniRigheRichieste] FOREIGN KEY ([IDRigaRichiesta]) REFERENCES [dbo].[OrdiniRigheRichieste] ([ID]),
    CONSTRAINT [FK_OrdiniRigheRichiesteDatiAggiuntivi_Tickets_Inserimento] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID]),
    CONSTRAINT [FK_OrdiniRigheRichiesteDatiAggiuntivi_Tickets_Modifica] FOREIGN KEY ([IDTicketModifica]) REFERENCES [dbo].[Tickets] ([ID])
);






GO
CREATE UNIQUE CLUSTERED INDEX [IXC_DataInserimento]
    ON [dbo].[OrdiniRigheRichiesteDatiAggiuntivi]([DataInserimento] ASC, [ID] ASC) WITH (FILLFACTOR = 70, DATA_COMPRESSION = PAGE);




GO
CREATE NONCLUSTERED INDEX [IX_IDRigaRichiesta]
    ON [dbo].[OrdiniRigheRichiesteDatiAggiuntivi]([IDRigaRichiesta] ASC, [IDDatoAggiuntivo] ASC, [Nome] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[OrdiniRigheRichiesteDatiAggiuntivi]([IDTicketModifica] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[OrdiniRigheRichiesteDatiAggiuntivi]([IDTicketInserimento] ASC);

