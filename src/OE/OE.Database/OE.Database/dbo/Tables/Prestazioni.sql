CREATE TABLE [dbo].[Prestazioni] (
    [ID]                        UNIQUEIDENTIFIER CONSTRAINT [DF_Prestazioni_ID] DEFAULT (newid()) NOT NULL,
    [DataInserimento]           DATETIME2 (0)    CONSTRAINT [DF_Prestazioni_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]              DATETIME2 (0)    NOT NULL,
    [IDTicketInserimento]       UNIQUEIDENTIFIER NOT NULL,
    [IDTicketModifica]          UNIQUEIDENTIFIER NOT NULL,
    [TS]                        ROWVERSION       NOT NULL,
    [Codice]                    VARCHAR (16)     NOT NULL,
    [Descrizione]               VARCHAR (256)    NULL,
    [Tipo]                      TINYINT          NOT NULL,
    [Provenienza]               TINYINT          NULL,
    [IDSistemaErogante]         UNIQUEIDENTIFIER NOT NULL,
    [Attivo]                    BIT              CONSTRAINT [DF_Prestazioni_Attivo] DEFAULT ((1)) NOT NULL,
    [UtenteInserimento]         VARCHAR (64)     CONSTRAINT [DF_Prestazioni_UtenteInserimento] DEFAULT ('System') NOT NULL,
    [UtenteModifica]            VARCHAR (64)     CONSTRAINT [DF_Prestazioni_UtenteModifica] DEFAULT ('System') NOT NULL,
    [CodiceSinonimo]            VARCHAR (16)     NULL,
    [Note]                      VARCHAR (1024)   NULL,
    [RichiedibileSoloDaProfilo] BIT              CONSTRAINT [DF_Prestazioni_SoloInProfilo] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Prestazioni] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_Prestazioni_Provenienza] CHECK ([Provenienza]=(0) OR [Provenienza]=(1) OR [Provenienza]=(2) OR [Provenienza]=(3) OR [Provenienza]=(4)),
    CONSTRAINT [CK_Prestazioni_RichSoloDaProfilo] CHECK ([RichiedibileSoloDaProfilo]=(1) AND [Tipo]=(0) OR [RichiedibileSoloDaProfilo]=(0)),
    CONSTRAINT [CK_Prestazioni_Tipo] CHECK ([Tipo]=(0) OR [Tipo]=(1) OR [Tipo]=(2) OR [Tipo]=(3)),
    CONSTRAINT [CK_Prestazioni_Tipo_IdSistema] CHECK ([Tipo]=(0) AND [IDSistemaErogante]<>'00000000-0000-0000-0000-000000000000' OR [Tipo]>(0) AND [IDSistemaErogante]='00000000-0000-0000-0000-000000000000'),
    CONSTRAINT [FK_Prestazioni_Sistemi] FOREIGN KEY ([IDSistemaErogante]) REFERENCES [dbo].[Sistemi] ([ID]),
    CONSTRAINT [FK_Prestazioni_Tickets_Inserimento] FOREIGN KEY ([IDTicketInserimento]) REFERENCES [dbo].[Tickets] ([ID]),
    CONSTRAINT [FK_Prestazioni_Tickets_Modifica] FOREIGN KEY ([IDTicketModifica]) REFERENCES [dbo].[Tickets] ([ID])
);














GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Prestazione; 1=Profilo blindato; 2=Profilo scomponibile; 3=Profilo utente;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Prestazioni', @level2type = N'COLUMN', @level2name = N'Tipo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Erogante;  1=Richiedente; 2=Ws; 3=Msg; 4=UI;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Prestazioni', @level2type = N'COLUMN', @level2name = N'Provenienza';


GO
CREATE NONCLUSTERED INDEX [IX_Tipo_Attivo]
    ON [dbo].[Prestazioni]([Tipo] ASC, [Attivo] ASC)
    INCLUDE([ID], [Codice], [Descrizione], [IDSistemaErogante]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketModifica]
    ON [dbo].[Prestazioni]([IDTicketModifica] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IDTicketInserimento]
    ON [dbo].[Prestazioni]([IDTicketInserimento] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SistemaErogante]
    ON [dbo].[Prestazioni]([IDSistemaErogante] ASC) WITH (FILLFACTOR = 70);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CodiceSistema]
    ON [dbo].[Prestazioni]([Codice] ASC, [IDSistemaErogante] ASC) WITH (FILLFACTOR = 70);

