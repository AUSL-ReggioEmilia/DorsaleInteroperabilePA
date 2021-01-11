CREATE TABLE [dbo].[RefertiNote] (
    [Id]            UNIQUEIDENTIFIER CONSTRAINT [DF_RefertiNote_ID] DEFAULT (newid()) NOT NULL,
    [IdRefertiBase] UNIQUEIDENTIFIER NOT NULL,
    [Utente]        VARCHAR (100)    NOT NULL,
    [Data]          DATETIME         NOT NULL,
    [Notificata]    BIT              CONSTRAINT [DF_RefertiNote_Notificata] DEFAULT ((0)) NOT NULL,
    [Nota]          TEXT             NOT NULL,
    [Cancellata]    BIT              CONSTRAINT [DF_RefertiNote_Cancellata] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RefertiNote] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [IX_RefertiNote_Data]
    ON [dbo].[RefertiNote]([Data] ASC) WITH (FILLFACTOR = 95);

