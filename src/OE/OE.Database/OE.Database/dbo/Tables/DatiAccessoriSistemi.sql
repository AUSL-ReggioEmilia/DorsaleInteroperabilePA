CREATE TABLE [dbo].[DatiAccessoriSistemi] (
    [ID]                   UNIQUEIDENTIFIER NOT NULL,
    [CodiceDatoAccessorio] VARCHAR (64)     NOT NULL,
    [IDSistema]            UNIQUEIDENTIFIER NOT NULL,
    [Attivo]               BIT              CONSTRAINT [DF_DatiAccessoriSistemi_Attivo] DEFAULT ((1)) NOT NULL,
    [Sistema]              BIT              NULL,
    [ValoreDefault]        VARCHAR (1024)   NULL,
    CONSTRAINT [PK_DatiAccessoriSistemi] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_DatiAccessoriSistemi_DatiAccessori] FOREIGN KEY ([CodiceDatoAccessorio]) REFERENCES [dbo].[DatiAccessori] ([Codice]),
    CONSTRAINT [FK_DatiAccessoriSistemi_Sistemi] FOREIGN KEY ([IDSistema]) REFERENCES [dbo].[Sistemi] ([ID])
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Unique]
    ON [dbo].[DatiAccessoriSistemi]([CodiceDatoAccessorio] ASC, [IDSistema] ASC) WITH (FILLFACTOR = 70);

