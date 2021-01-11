CREATE TABLE [dbo].[SistemiErogantiDocumenti] (
    [Id]                UNIQUEIDENTIFIER CONSTRAINT [DF_SistemiErogantiDocumenti_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [IdSistemaErogante] UNIQUEIDENTIFIER NOT NULL,
    [Contenuto]         IMAGE            NOT NULL,
    [Nome]              VARCHAR (256)    NOT NULL,
    [Estensione]        VARCHAR (50)     NOT NULL,
    [Dimensione]        INT              NOT NULL,
    [ContentType]       VARCHAR (256)    NOT NULL,
    CONSTRAINT [PK_SistemiErogantiDocumenti] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [IX_SistemiErogantiDocumenti_IdSistemaErogante] UNIQUE NONCLUSTERED ([IdSistemaErogante] ASC) WITH (FILLFACTOR = 95)
);

