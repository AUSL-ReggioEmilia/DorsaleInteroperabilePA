CREATE TABLE [dbo].[PazientiCancellati] (
    [Id]                UNIQUEIDENTIFIER CONSTRAINT [DF_PazientiCancellati_Id] DEFAULT (newid()) NOT NULL,
    [IdPazientiBase]    UNIQUEIDENTIFIER NOT NULL,
    [IdRepartiEroganti] UNIQUEIDENTIFIER NULL,
    [DataCancellazione] DATETIME         CONSTRAINT [DF_PazientiCancellati_DataCancellazione] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PazientiCancellati] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PazientiCancellati', @level2type = N'COLUMN', @level2name = N'DataCancellazione';

