CREATE TABLE [dbo].[DizionariLhaMedici] (
    [CodiceInterno]           NUMERIC (7)   NOT NULL,
    [CodiceRegionale]         NUMERIC (7)   NOT NULL,
    [CognomeNome]             NVARCHAR (35) NOT NULL,
    [CodiceFiscale]           NVARCHAR (16) NULL,
    [Sesso]                   NVARCHAR (1)  NULL,
    [DataNascita]             DATETIME      NULL,
    [CodiceTipoMedico]        NVARCHAR (1)  NOT NULL,
    [DescrizioneTipoMedico]   NVARCHAR (30) NULL,
    [DataCessazione]          DATETIME      NULL,
    [TimestampUltimaModifica] DATETIME      NOT NULL,
    [CodiceDistretto]         NUMERIC (7)   NULL,
    [DescrizioneDistretto]    NVARCHAR (35) NULL,
    CONSTRAINT [PK_DizionariLhaMedici] PRIMARY KEY CLUSTERED ([CodiceInterno] ASC) WITH (FILLFACTOR = 95)
);




GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionariLhaMedici] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionariLhaMedici] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionariLhaMedici] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionariLhaMedici] TO [DataAccessSSIS]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Codice regionale usato per l''invio in regione dei flussi relativi ai MMG', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DizionariLhaMedici', @level2type = N'COLUMN', @level2name = N'CodiceRegionale';

