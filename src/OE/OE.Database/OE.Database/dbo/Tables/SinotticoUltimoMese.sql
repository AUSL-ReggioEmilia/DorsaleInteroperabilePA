CREATE TABLE [dbo].[SinotticoUltimoMese] (
    [Id]                   UNIQUEIDENTIFIER NOT NULL,
    [IdSistemaErogante]    UNIQUEIDENTIFIER NOT NULL,
    [IdSistemaRichiedente] UNIQUEIDENTIFIER NOT NULL,
    [Stato]                VARCHAR (100)    NOT NULL,
    [Giorno]               DATE             NOT NULL,
    [NumeroOrdini]         INT              NULL,
    CONSTRAINT [PK_SinotticoUltimoMese] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_SinotticoUltimoMese_IdSistemaErogante] FOREIGN KEY ([IdSistemaErogante]) REFERENCES [dbo].[Sistemi] ([ID]),
    CONSTRAINT [FK_SinotticoUltimoMese_IdSistemaRichiedente] FOREIGN KEY ([IdSistemaRichiedente]) REFERENCES [dbo].[Sistemi] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_IdSistemaRichiedente]
    ON [dbo].[SinotticoUltimoMese]([IdSistemaRichiedente] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IdSistemaErogante]
    ON [dbo].[SinotticoUltimoMese]([IdSistemaErogante] ASC) WITH (FILLFACTOR = 70);


GO
CREATE CLUSTERED INDEX [IX_SinotticoUltimoMese]
    ON [dbo].[SinotticoUltimoMese]([Giorno] DESC) WITH (FILLFACTOR = 70);

