CREATE TABLE [dbo].[PazientiNotificheUtenti_Storico] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [IdPazientiNotifica] UNIQUEIDENTIFIER NOT NULL,
    [InvioUtente]        VARCHAR (64)     NULL,
    [InvioData]          DATETIME         NULL,
    [InvioEffettuato]    BIT              NOT NULL,
    [InvioSoapUrl]       VARCHAR (255)    NULL
);

