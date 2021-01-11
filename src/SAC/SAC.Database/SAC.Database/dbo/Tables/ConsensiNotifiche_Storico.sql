CREATE TABLE [dbo].[ConsensiNotifiche_Storico] (
    [Id]         UNIQUEIDENTIFIER NOT NULL,
    [IdConsenso] UNIQUEIDENTIFIER NOT NULL,
    [Tipo]       TINYINT          NOT NULL,
    [Data]       DATETIME         NOT NULL,
    [Utente]     VARCHAR (64)     NOT NULL
);

