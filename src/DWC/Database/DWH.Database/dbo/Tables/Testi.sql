﻿CREATE TABLE [dbo].[Testi] (
    [Id]     UNIQUEIDENTIFIER CONSTRAINT [DF_Testi_Id] DEFAULT (newid()) NOT NULL,
    [Codice] VARCHAR (20)     NOT NULL,
    [Testo]  VARCHAR (8000)   NOT NULL,
    CONSTRAINT [PK_Testi] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Testi]
    ON [dbo].[Testi]([Codice] ASC) WITH (FILLFACTOR = 95);

