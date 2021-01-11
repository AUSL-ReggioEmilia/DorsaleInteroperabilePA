CREATE TABLE [dbo].[DizionariLhaComuni] (
    [CodiceInternoComune]     NUMERIC (6)   NOT NULL,
    [DescrizioneComune]       NVARCHAR (35) NOT NULL,
    [IstatComune]             VARCHAR (6)   NOT NULL,
    [CodiceDistretto]         NVARCHAR (5)  NULL,
    [DataInizioValidita]      DATETIME      NULL,
    [DataFineValidita]        DATETIME      NULL,
    [Cap]                     NVARCHAR (7)  NULL,
    [CodiceCatastale]         NVARCHAR (4)  NULL,
    [CodiceRegione]           VARCHAR (3)   NULL,
    [CodiceProvincia]         NVARCHAR (2)  NULL,
    [CodiceAsl]               NUMERIC (3)   NULL,
    [FlagComuneStatoEstero]   NVARCHAR (1)  NOT NULL,
    [FlagStatoEsteroUE]       NVARCHAR (1)  NOT NULL,
    [TimestampUltimaModifica] DATETIME      NOT NULL,
    [Disattivato]             BIT           CONSTRAINT [DF_DizionariLhaComuni_Disattivato] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_DizionariLhaComuni] PRIMARY KEY CLUSTERED ([CodiceInternoComune] ASC) WITH (FILLFACTOR = 95)
);


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionariLhaComuni] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionariLhaComuni] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionariLhaComuni] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionariLhaComuni] TO [DataAccessSSIS]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Solo per comuni NON multi-cap', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DizionariLhaComuni', @level2type = N'COLUMN', @level2name = N'Cap';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'C=Comune; E=Estero;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DizionariLhaComuni', @level2type = N'COLUMN', @level2name = N'FlagComuneStatoEstero';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'S=paese UE; N=paese extra UE;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DizionariLhaComuni', @level2type = N'COLUMN', @level2name = N'FlagStatoEsteroUE';

