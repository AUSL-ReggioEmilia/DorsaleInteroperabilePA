CREATE TABLE [dbo].[PazientiDropTable] (
    [Id]             INT          IDENTITY (1, 1) NOT NULL,
    [DataLog]        DATETIME     CONSTRAINT [DF_PazientiDropTable_DataLog] DEFAULT (getdate()) NOT NULL,
    [TipoOperazione] TINYINT      NOT NULL,
    [IdLha]          NUMERIC (10) NOT NULL,
    [Inviato]        BIT          CONSTRAINT [DF_PazientiDropTable_Inviato] DEFAULT ((0)) NOT NULL,
    [DataInvio]      DATETIME     NULL,
    [Motivo]         VARCHAR (64) NULL,
    CONSTRAINT [PK_PazientiDropTable] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiDropTable_Inviato]
    ON [dbo].[PazientiDropTable]([DataLog] ASC, [Inviato] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Da inserire; 1=Da modificare; 2= Da eliminare;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PazientiDropTable', @level2type = N'COLUMN', @level2name = N'TipoOperazione';

