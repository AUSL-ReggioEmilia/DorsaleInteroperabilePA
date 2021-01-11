CREATE TABLE [dbo].[ConsensiNotificheUtenti] (
    [Id]                 UNIQUEIDENTIFIER CONSTRAINT [DF_ConsensiNotificheUtenti_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [IdConsensiNotifica] UNIQUEIDENTIFIER NOT NULL,
    [InvioUtente]        VARCHAR (64)     NULL,
    [InvioData]          DATETIME         NULL,
    [InvioEffettuato]    BIT              CONSTRAINT [DF_ConsensiNotificheUtenti_InvioEffettuato] DEFAULT ((0)) NOT NULL,
    [InvioSoapUrl]       VARCHAR (255)    NULL,
    [Date]               DATETIME         CONSTRAINT [DF_ConsensiNotificheUtenti_Date] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ConsensiNotificheUtenti] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_ConsensiNotificheUtenti_ConsensiNotifiche] FOREIGN KEY ([IdConsensiNotifica]) REFERENCES [dbo].[ConsensiNotifiche] ([Id]),
    CONSTRAINT [FK_ConsensiNotificheUtenti_ConsensiUtenti] FOREIGN KEY ([InvioUtente]) REFERENCES [dbo].[ConsensiUtenti] ([Utente])
);


GO
CREATE CLUSTERED INDEX [IX_ConsensiNotificheUtenti_Date]
    ON [dbo].[ConsensiNotificheUtenti]([Date] ASC);

