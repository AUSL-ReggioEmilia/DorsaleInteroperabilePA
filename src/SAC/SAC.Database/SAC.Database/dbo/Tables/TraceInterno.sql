CREATE TABLE [dbo].[TraceInterno] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [DataTrace]   DATETIME       CONSTRAINT [DF_TraceInterno_DataTrace] DEFAULT (getdate()) NOT NULL,
    [Utente]      VARCHAR (64)   NOT NULL,
    [Contesto]    VARCHAR (64)   NOT NULL,
    [Descrizione] VARCHAR (1024) NULL,
    CONSTRAINT [PK_TraceInterno] PRIMARY KEY CLUSTERED ([Id] ASC)
);

