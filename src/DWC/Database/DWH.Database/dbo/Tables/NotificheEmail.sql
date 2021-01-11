CREATE TABLE [dbo].[NotificheEmail] (
    [Id]                      INT            IDENTITY (1, 1) NOT NULL,
    [Mittente]                VARCHAR (128)  NULL,
    [Destinatario]            VARCHAR (512)  NOT NULL,
    [CopiaConoscenza]         VARCHAR (512)  NULL,
    [CopiaConoscenzaNascosta] VARCHAR (512)  NULL,
    [Oggetto]                 VARCHAR (1024) NULL,
    [Messaggio]               TEXT           NULL,
    [Inviata]                 BIT            CONSTRAINT [DF_NotificheEmail_Inviata] DEFAULT ((0)) NOT NULL,
    [DataInserimento]         DATETIME       CONSTRAINT [DF_NotificheEmail_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataInvio]               DATETIME       NULL,
    [NumeroTentativi]         INT            NULL,
    CONSTRAINT [PK_NotificheEmail] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);




GO
CREATE NONCLUSTERED INDEX [IX_NotificheEmail_Inviata]
    ON [dbo].[NotificheEmail]([Inviata] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_NotificheEmail_DataInserimento_Mittente]
    ON [dbo].[NotificheEmail]([DataInserimento] ASC, [Mittente] ASC) WITH (FILLFACTOR = 95);

