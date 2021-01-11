CREATE TABLE [dbo].[PazientiIncoerenzaIstat] (
    [Id]              UNIQUEIDENTIFIER CONSTRAINT [DF_PazientiIncoerenzaIstat_Id] DEFAULT (newid()) NOT NULL,
    [DataInserimento] DATETIME         CONSTRAINT [DF_PazientiIncoerenzaIstat_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [Provenienza]     VARCHAR (16)     NOT NULL,
    [IdProvenienza]   VARCHAR (64)     NOT NULL,
    [CodiceIstat]     VARCHAR (6)      NOT NULL,
    [GeneratoDa]      VARCHAR (64)     NOT NULL,
    [Motivo]          VARCHAR (64)     NOT NULL,
    CONSTRAINT [PK_PazientiIncoerenzaIstat] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE CLUSTERED INDEX [IXC_DataInserimento_Provenienza_IdProvenienza]
    ON [dbo].[PazientiIncoerenzaIstat]([DataInserimento] ASC, [Provenienza] ASC, [IdProvenienza] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_DataInserimento_CodiceIstat]
    ON [dbo].[PazientiIncoerenzaIstat]([DataInserimento] ASC, [CodiceIstat] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Esempio: MSG,WS', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PazientiIncoerenzaIstat', @level2type = N'COLUMN', @level2name = N'GeneratoDa';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Il motivo dell''incoerenza ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PazientiIncoerenzaIstat', @level2type = N'COLUMN', @level2name = N'Motivo';

