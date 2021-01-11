CREATE TABLE [dbo].[LayerRefertiFormati] (
    [Id]                UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_LayerRefertiFormati_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_LayerRefertiFormati_DataModifica] DEFAULT (getdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_LayerRefertiFormati_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_LayerRefertiFormati_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    [AziendaErogante]   VARCHAR (16)     NOT NULL,
    [SistemaErogante]   VARCHAR (16)     NOT NULL,
    [RepartoErogante]   VARCHAR (64)     NULL,
    [Descrizione]       VARCHAR (128)    NOT NULL,
    CONSTRAINT [PK_LayerRefertiFormati] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_LayerRefertiFormati_AziendaSistemaReparto]
    ON [dbo].[LayerRefertiFormati]([AziendaErogante] ASC, [SistemaErogante] ASC, [RepartoErogante] ASC, [Descrizione] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Questo è il codice che identifica il "formato referto" e dovrà essere uguale in tutte le installazioni', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LayerRefertiFormati', @level2type = N'COLUMN', @level2name = N'Id';

