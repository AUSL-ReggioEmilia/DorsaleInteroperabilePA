CREATE TABLE [dbo].[AbbonamentiRepartiRicovero] (
    [Id]                               UNIQUEIDENTIFIER CONSTRAINT [DF_AbbonamentiRepartiRicovero_Id] DEFAULT (newid()) NOT NULL,
    [IdUtenti]                         UNIQUEIDENTIFIER NOT NULL,
    [IdRepartiRicoveroSistemiEroganti] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_AbbonamentiRepartiRicovero] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AbbonamentiRepartiRicovero]
    ON [dbo].[AbbonamentiRepartiRicovero]([IdRepartiRicoveroSistemiEroganti] ASC, [IdUtenti] ASC) WITH (FILLFACTOR = 95);

