CREATE TABLE [dbo].[PazientiNotifiche] (
    [Id]             UNIQUEIDENTIFIER CONSTRAINT [DF_PazientiNotifiche_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [IdPaziente]     UNIQUEIDENTIFIER NOT NULL,
    [Tipo]           TINYINT          NOT NULL,
    [Data]           DATETIME         CONSTRAINT [DF_PazientiNotifiche_Data] DEFAULT (getdate()) NOT NULL,
    [Utente]         VARCHAR (64)     NOT NULL,
    [IdPazienteFuso] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_PazientiNotifiche] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_PazientiNotifiche_Pazienti] FOREIGN KEY ([IdPaziente]) REFERENCES [dbo].[Pazienti] ([Id])
);






GO
CREATE CLUSTERED INDEX [IX_PazientiNotifiche_Data]
    ON [dbo].[PazientiNotifiche]([Data] ASC, [Tipo] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Msg; 1= UI; 2=WS; 3=Batch;4=Msg-notifica merge;5=UI-notifica merge; 6=ws-merge ; 7=Aggiornamento Padre per notifica DataDecesso; 8=Modifica consenso; 9=Modifica esenzione', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PazientiNotifiche', @level2type = N'COLUMN', @level2name = N'Tipo';






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valorizzato sono in caso di fusione di IdPazienteFuso in IdPaziente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PazientiNotifiche', @level2type = N'COLUMN', @level2name = N'IdPazienteFuso';

