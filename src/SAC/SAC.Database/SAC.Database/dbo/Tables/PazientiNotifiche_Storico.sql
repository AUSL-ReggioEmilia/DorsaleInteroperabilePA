CREATE TABLE [dbo].[PazientiNotifiche_Storico] (
    [Id]             UNIQUEIDENTIFIER NOT NULL,
    [IdPaziente]     UNIQUEIDENTIFIER NOT NULL,
    [Tipo]           TINYINT          NOT NULL,
    [Data]           DATETIME         NOT NULL,
    [Utente]         VARCHAR (64)     NOT NULL,
    [IdPazienteFuso] UNIQUEIDENTIFIER NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valorizzato sono in caso di fusione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PazientiNotifiche_Storico', @level2type = N'COLUMN', @level2name = N'IdPazienteFuso';

