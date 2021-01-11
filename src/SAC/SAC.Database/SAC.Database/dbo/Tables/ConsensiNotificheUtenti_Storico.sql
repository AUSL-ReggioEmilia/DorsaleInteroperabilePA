CREATE TABLE [dbo].[ConsensiNotificheUtenti_Storico] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [IdConsensiNotifica] UNIQUEIDENTIFIER NOT NULL,
    [InvioUtente]        VARCHAR (64)     NULL,
    [InvioData]          DATETIME         NULL,
    [InvioEffettuato]    BIT              NOT NULL,
    [InvioSoapUrl]       VARCHAR (255)    NULL
);

