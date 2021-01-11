CREATE TABLE [dbo].[DatiAccessoriPrestazioni] (
    [ID]                   UNIQUEIDENTIFIER NOT NULL,
    [CodiceDatoAccessorio] VARCHAR (64)     NOT NULL,
    [IDPrestazione]        UNIQUEIDENTIFIER NOT NULL,
    [Attivo]               BIT              CONSTRAINT [DF_DatiAccessoriPrestazioni_Attivo] DEFAULT ((1)) NOT NULL,
    [Sistema]              BIT              NULL,
    [ValoreDefault]        VARCHAR (1024)   NULL,
    CONSTRAINT [PK_DatiAccessoriPrestazioni] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_DatiAccessoriPrestazioni_DatiAccessori] FOREIGN KEY ([CodiceDatoAccessorio]) REFERENCES [dbo].[DatiAccessori] ([Codice]),
    CONSTRAINT [FK_DatiAccessoriPrestazioni_Prestazioni] FOREIGN KEY ([IDPrestazione]) REFERENCES [dbo].[Prestazioni] ([ID])
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Unique]
    ON [dbo].[DatiAccessoriPrestazioni]([CodiceDatoAccessorio] ASC, [IDPrestazione] ASC) WITH (FILLFACTOR = 70);

