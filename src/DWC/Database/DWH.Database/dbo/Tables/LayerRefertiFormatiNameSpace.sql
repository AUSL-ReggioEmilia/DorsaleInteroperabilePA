CREATE TABLE [dbo].[LayerRefertiFormatiNameSpace] (
    [Id]                    UNIQUEIDENTIFIER CONSTRAINT [DF_LayerRefertiFormatiNameSpace_Id] DEFAULT (newid()) NOT NULL,
    [DataInserimento]       DATETIME         CONSTRAINT [DF_LayerRefertiFormatiNameSpace_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]          DATETIME         CONSTRAINT [DF_LayerRefertiFormatiNameSpace_DataModifica] DEFAULT (getdate()) NOT NULL,
    [UtenteInserimento]     VARCHAR (128)    CONSTRAINT [DF_LayerRefertiFormatiNameSpace_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]        VARCHAR (128)    CONSTRAINT [DF_LayerRefertiFormatiNameSpace_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    [IdLayerRefertiFormati] UNIQUEIDENTIFIER NOT NULL,
    [NameSpace]             VARCHAR (64)     NULL,
    [Xslt]                  VARCHAR (MAX)    NOT NULL,
    [ElaboraDati]           TINYINT          CONSTRAINT [DF_LayerRefertiFormatiNameSpace_ElaboraDati] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_LayerRefertiFormatiNameSpace] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_LayerRefertiFormatiNameSpace_LayerRefertiFormati] FOREIGN KEY ([IdLayerRefertiFormati]) REFERENCES [dbo].[LayerRefertiFormati] ([Id]) NOT FOR REPLICATION
);


GO
CREATE CLUSTERED INDEX [FX_LayerRefertiFormatiNameSpace_IdLayerRefertiFormati]
    ON [dbo].[LayerRefertiFormatiNameSpace]([IdLayerRefertiFormati] ASC, [NameSpace] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Il nome dello stile presente nella tabella RefertiStili', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LayerRefertiFormatiNameSpace', @level2type = N'COLUMN', @level2name = N'NameSpace';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'La trasformazione da utilizzare per la presentazione dei dati', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LayerRefertiFormatiNameSpace', @level2type = N'COLUMN', @level2name = N'Xslt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica dove trovare i dati da elòaborare. 0=Dati Dwh(es.: attributi), 1=XML originale negli allegati', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LayerRefertiFormatiNameSpace', @level2type = N'COLUMN', @level2name = N'ElaboraDati';

