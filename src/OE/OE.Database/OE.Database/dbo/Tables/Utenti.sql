CREATE TABLE [dbo].[Utenti] (
    [ID]          UNIQUEIDENTIFIER CONSTRAINT [DF_Utenti_ID] DEFAULT (newid()) NOT NULL,
    [Utente]      VARCHAR (256)    NULL,
    [Descrizione] VARCHAR (1024)   NULL,
    [Attivo]      BIT              CONSTRAINT [DF_Utenti_Attivo] DEFAULT ((1)) NOT NULL,
    [Delega]      TINYINT          NOT NULL,
    [Tipo]        TINYINT          CONSTRAINT [DF_Utenti_Tipo] DEFAULT ((0)) NOT NULL,
    [ObjectGuid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Utenti] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_Utenti_Delega] CHECK ([Delega]=(0) OR [Delega]=(1) OR [Delega]=(2))
);






GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Nessuna delega; 1=Può delegare; 2=Deve delegare;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Utenti', @level2type = N'COLUMN', @level2name = N'Delega';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Utente: 1=Gruppo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Utenti', @level2type = N'COLUMN', @level2name = N'Tipo';


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Unique]
    ON [dbo].[Utenti]([Utente] ASC) WITH (FILLFACTOR = 70);

