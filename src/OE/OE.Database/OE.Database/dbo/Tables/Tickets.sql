CREATE TABLE [dbo].[Tickets] (
    [ID]            UNIQUEIDENTIFIER CONSTRAINT [DF_Tickets_ID] DEFAULT (newid()) NOT NULL,
    [DataCreazione] DATETIME2 (0)    CONSTRAINT [DF_Tickets_DataCreazione] DEFAULT (getdate()) NOT NULL,
    [DataLettura]   DATETIME2 (0)    NOT NULL,
    [IDUtente]      UNIQUEIDENTIFIER NOT NULL,
    [UserName]      VARCHAR (64)     NOT NULL,
    [TTL]           INT              NOT NULL,
    CONSTRAINT [PK_Tickets] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_Tickets_Utenti] FOREIGN KEY ([IDUtente]) REFERENCES [dbo].[Utenti] ([ID])
);






GO
CREATE NONCLUSTERED INDEX [IX_IdUtenteUserName]
    ON [dbo].[Tickets]([UserName] ASC, [IDUtente] ASC)
    INCLUDE([DataLettura]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica l''ultima lettura effettuata e confrontata con il TTL.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tickets', @level2type = N'COLUMN', @level2name = N'DataLettura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica l''utente loggato (My.User.Name).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tickets', @level2type = N'COLUMN', @level2name = N'UserName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Minuti di validità del ticket. Se impostato a 0 il ticket ha una durata infinita.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tickets', @level2type = N'COLUMN', @level2name = N'TTL';


GO



GO
CREATE NONCLUSTERED INDEX [IX_DataLettura]
    ON [dbo].[Tickets]([DataLettura] ASC);

