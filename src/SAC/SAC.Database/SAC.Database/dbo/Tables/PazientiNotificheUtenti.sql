CREATE TABLE [dbo].[PazientiNotificheUtenti] (
    [Id]                 UNIQUEIDENTIFIER CONSTRAINT [DF_PazientiNotificheUtenti_Id] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [IdPazientiNotifica] UNIQUEIDENTIFIER NOT NULL,
    [InvioUtente]        VARCHAR (64)     NULL,
    [InvioData]          DATETIME         NULL,
    [InvioEffettuato]    BIT              CONSTRAINT [DF_PazientiNotificheInvioEffettuato] DEFAULT ((0)) NOT NULL,
    [InvioSoapUrl]       VARCHAR (255)    NULL,
    [Date]               DATETIME         CONSTRAINT [DF_PazientiNotificheUtenti_Date] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PazientiNotificheUtenti] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_PazientiNotificheUtenti_PazientiNotifiche] FOREIGN KEY ([IdPazientiNotifica]) REFERENCES [dbo].[PazientiNotifiche] ([Id]),
    CONSTRAINT [FK_PazientiNotificheUtenti_PazientiUtenti] FOREIGN KEY ([InvioUtente]) REFERENCES [dbo].[PazientiUtenti] ([Utente])
);


GO
CREATE NONCLUSTERED INDEX [FK_PazientiNotificheUtenti_IdPaziente]
    ON [dbo].[PazientiNotificheUtenti]([IdPazientiNotifica] ASC, [InvioEffettuato] ASC);

