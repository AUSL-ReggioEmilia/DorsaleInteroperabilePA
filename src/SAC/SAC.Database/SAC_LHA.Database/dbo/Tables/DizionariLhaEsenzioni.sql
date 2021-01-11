CREATE TABLE [dbo].[DizionariLhaEsenzioni] (
    [CodiceEsenzione]         NVARCHAR (12)  NOT NULL,
    [DescrizioneEsenzione]    NVARCHAR (35)  NOT NULL,
    [NoteEsenzione]           NVARCHAR (300) NULL,
    [CodiceTipoEsenzione]     NVARCHAR (1)   NOT NULL,
    [QuotaFissa]              NVARCHAR (1)   NOT NULL,
    [DataScadenzaEsenzione]   DATETIME       NULL,
    [Prescrivibile]           NVARCHAR (1)   NOT NULL,
    [GiorniValidita]          NUMERIC (5)    NULL,
    [EtaMinima]               NUMERIC (3)    NULL,
    [EtaMassima]              NUMERIC (3)    NULL,
    [TimestampUltimaModifica] DATETIME       NOT NULL,
    CONSTRAINT [PK_DizionariLhaEsenzioni] PRIMARY KEY CLUSTERED ([CodiceEsenzione] ASC) WITH (FILLFACTOR = 95)
);


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionariLhaEsenzioni] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionariLhaEsenzioni] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionariLhaEsenzioni] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionariLhaEsenzioni] TO [DataAccessSSIS]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'P=Patologia; C=Categoria;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DizionariLhaEsenzioni', @level2type = N'COLUMN', @level2name = N'CodiceTipoEsenzione';

