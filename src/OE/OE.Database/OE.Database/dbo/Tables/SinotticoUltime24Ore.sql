CREATE TABLE [dbo].[SinotticoUltime24Ore] (
    [Id]                   UNIQUEIDENTIFIER NOT NULL,
    [IdSistemaErogante]    UNIQUEIDENTIFIER NOT NULL,
    [IdSistemaRichiedente] UNIQUEIDENTIFIER NOT NULL,
    [Stato]                VARCHAR (100)    NOT NULL,
    [Giorno]               DATE             NOT NULL,
    [NumeroOrdini]         INT              NULL,
    CONSTRAINT [PK_SinotticoUltime24Ore] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_SinotticoUltime24Ore_IdSistemaErogante] FOREIGN KEY ([IdSistemaErogante]) REFERENCES [dbo].[Sistemi] ([ID]),
    CONSTRAINT [FK_SinotticoUltime24Ore_IdSistemaRichiedente] FOREIGN KEY ([IdSistemaRichiedente]) REFERENCES [dbo].[Sistemi] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_IdSistemaRichiedente]
    ON [dbo].[SinotticoUltime24Ore]([IdSistemaRichiedente] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IdSistemaErogante]
    ON [dbo].[SinotticoUltime24Ore]([IdSistemaErogante] ASC) WITH (FILLFACTOR = 70);


GO
CREATE CLUSTERED INDEX [IX_SinotticoUltime24Ore]
    ON [dbo].[SinotticoUltime24Ore]([Giorno] DESC) WITH (FILLFACTOR = 70);

