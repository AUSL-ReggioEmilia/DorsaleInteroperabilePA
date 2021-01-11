CREATE TABLE [dbo].[IstatComuni] (
    [Codice]                VARCHAR (6)   NOT NULL,
    [Nome]                  VARCHAR (128) NOT NULL,
    [CodiceProvincia]       VARCHAR (3)   NULL,
    [Nazione]               BIT           CONSTRAINT [DF_IstatComuni_Nazione] DEFAULT ((0)) NULL,
    [Provenienza]           VARCHAR (16)  NULL,
    [IdProvenienza]         VARCHAR (64)  NULL,
    [DataInserimento]       DATETIME      CONSTRAINT [DF_IstatComuni_DataInserimento] DEFAULT (getdate()) NULL,
    [DataInizioValidita]    DATETIME      CONSTRAINT [DF_IstatComuni_DataInizioValidita] DEFAULT ('1800-01-01') NOT NULL,
    [DataFineValidita]      DATETIME      NULL,
    [CodiceDistretto]       VARCHAR (5)   NULL,
    [Cap]                   VARCHAR (7)   NULL,
    [CodiceCatastale]       VARCHAR (4)   NULL,
    [CodiceRegione]         VARCHAR (3)   NULL,
    [Sigla]                 VARCHAR (2)   NULL,
    [CodiceAsl]             NUMERIC (3)   NULL,
    [FlagComuneStatoEstero] VARCHAR (1)   NULL,
    [FlagStatoEsteroUE]     VARCHAR (1)   NULL,
    [DataUltimaModifica]    DATETIME      NULL,
    [Disattivato]           BIT           NULL,
    [CodiceInternoLha]      NUMERIC (6)   NULL,
    CONSTRAINT [PK_IstatComuni] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_IstatComuni_IstatProvince] FOREIGN KEY ([CodiceProvincia]) REFERENCES [dbo].[IstatProvince] ([Codice])
);


GO
CREATE NONCLUSTERED INDEX [IX_IstatComuni_Nome]
    ON [dbo].[IstatComuni]([Nome] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IstatComuni_Provenienza_IdProvenienza]
    ON [dbo].[IstatComuni]([Provenienza] ASC, [IdProvenienza] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_IstatComuni_DataInizioValidita_DataFineValidita_Nazione]
    ON [dbo].[IstatComuni]([DataInizioValidita] ASC, [DataFineValidita] ASC, [Nazione] ASC) WITH (FILLFACTOR = 95);


GO
GRANT SELECT
    ON OBJECT::[dbo].[IstatComuni] TO [DataAccessSql]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'In DizionariLhaComuni si chiama CodiceProvincia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IstatComuni', @level2type = N'COLUMN', @level2name = N'Sigla';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Il campo LHA.TimestampUltimaModifica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IstatComuni', @level2type = N'COLUMN', @level2name = N'DataUltimaModifica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Il campo LHA.CodiceInternoComune', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IstatComuni', @level2type = N'COLUMN', @level2name = N'CodiceInternoLha';

