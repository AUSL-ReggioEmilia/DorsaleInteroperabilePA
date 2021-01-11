CREATE TABLE [dbo].[PazientiAnonimizzazioni] (
    [IdAnonimo]       VARCHAR (16)     NOT NULL,
    [IdSacAnonimo]    UNIQUEIDENTIFIER NOT NULL,
    [IdSacOriginale]  UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento] DATETIME         CONSTRAINT [DF_Anonimizzazioni_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [Utente]          VARCHAR (64)     NOT NULL,
    [Note]            VARCHAR (2048)   NULL,
    CONSTRAINT [PK_PazientiAnonimizzazioni] PRIMARY KEY CLUSTERED ([IdAnonimo] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_PazientiAnonimizzazioni_Pazienti_IdSacAnonimo] FOREIGN KEY ([IdSacAnonimo]) REFERENCES [dbo].[Pazienti] ([Id]),
    CONSTRAINT [FK_PazientiAnonimizzazioni_Pazienti_IdSacOriginale] FOREIGN KEY ([IdSacOriginale]) REFERENCES [dbo].[Pazienti] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiAnonimizzazioni_IdSacOriginale]
    ON [dbo].[PazientiAnonimizzazioni]([IdSacOriginale] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiAnonimizzazioni_IdSacAnonimo]
    ON [dbo].[PazientiAnonimizzazioni]([IdSacAnonimo] ASC) WITH (FILLFACTOR = 95);

