CREATE TABLE [dbo].[Utenti] (
    [Id]            UNIQUEIDENTIFIER NOT NULL,
    [DomainName]    VARCHAR (32)     NOT NULL,
    [AccountName]   VARCHAR (64)     NOT NULL,
    [Nome]          VARCHAR (128)    NULL,
    [Email]         VARCHAR (256)    NULL,
    [UtenteTecnico] BIT              CONSTRAINT [DF_Utenti_UtenteTecnico] DEFAULT ((0)) NOT NULL,
    [Descrizione]   VARCHAR (128)    NULL,
    [AccessoWs]     BIT              CONSTRAINT [DF_Utenti_AccessoWs] DEFAULT ((0)) NOT NULL,
    [IdRuolo]       UNIQUEIDENTIFIER NULL,
    [Utente]        VARCHAR (128)    NOT NULL,
    CONSTRAINT [PK_Utenti] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE UNIQUE CLUSTERED INDEX [IXC_Utenti_Utente]
    ON [dbo].[Utenti]([Id] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Utenti_DomainName_AccountName]
    ON [dbo].[Utenti]([DomainName] ASC, [AccountName] ASC) WITH (FILLFACTOR = 95);


GO
GRANT DELETE
    ON OBJECT::[dbo].[Utenti] TO [Adsi Asmn Ausl]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Utenti] TO [Adsi Asmn Ausl]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Utenti] TO [Adsi Asmn Ausl]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Utenti] TO [Adsi Asmn Ausl]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica gli account usati dal web service DWH', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Utenti', @level2type = N'COLUMN', @level2name = N'AccessoWs';

