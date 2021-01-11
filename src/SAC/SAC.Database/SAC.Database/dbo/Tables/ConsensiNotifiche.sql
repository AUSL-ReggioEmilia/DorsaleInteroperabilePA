CREATE TABLE [dbo].[ConsensiNotifiche] (
    [Id]         UNIQUEIDENTIFIER CONSTRAINT [DF_ConsensiNotifiche_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [IdConsenso] UNIQUEIDENTIFIER NOT NULL,
    [Tipo]       TINYINT          NOT NULL,
    [Data]       DATETIME         CONSTRAINT [DF_ConsensiNotifiche_Data] DEFAULT (getdate()) NOT NULL,
    [Utente]     VARCHAR (64)     NOT NULL,
    CONSTRAINT [PK_ConsensiNotifiche] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_ConsensiNotifiche_Consensi] FOREIGN KEY ([IdConsenso]) REFERENCES [dbo].[Consensi] ([Id])
);


GO
CREATE CLUSTERED INDEX [IX_ConsensiNotifiche_Date]
    ON [dbo].[ConsensiNotifiche]([Data] ASC, [Tipo] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Msg; 1= UI; 2=WS', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConsensiNotifiche', @level2type = N'COLUMN', @level2name = N'Tipo';

