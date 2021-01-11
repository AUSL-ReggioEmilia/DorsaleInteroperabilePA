CREATE TABLE [dbo].[EntitaAccessi] (
    [Id]             UNIQUEIDENTIFIER CONSTRAINT [DF_EntitaAccessi_Id] DEFAULT (newid()) NOT NULL,
    [Nome]           VARCHAR (128)    NOT NULL,
    [Descrizione1]   VARCHAR (256)    NULL,
    [Descrizione2]   VARCHAR (256)    NULL,
    [Descrizione3]   VARCHAR (256)    NULL,
    [Dominio]        VARCHAR (64)     NOT NULL,
    [Tipo]           TINYINT          NOT NULL,
    [Amministratore] BIT              CONSTRAINT [DF_EntitaAccessi_Amministratore] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_EntitaAccessi] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EntitaAccessiNomeDominio]
    ON [dbo].[EntitaAccessi]([Nome] ASC, [Dominio] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Gruppo;2=Utente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EntitaAccessi', @level2type = N'COLUMN', @level2name = N'Tipo';

