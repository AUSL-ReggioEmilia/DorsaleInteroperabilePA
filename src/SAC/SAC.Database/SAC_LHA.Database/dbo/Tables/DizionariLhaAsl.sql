CREATE TABLE [dbo].[DizionariLhaAsl] (
    [CodiceRegione]           VARCHAR (3)   NOT NULL,
    [CodiceAsl]               NUMERIC (3)   NOT NULL,
    [DescrizioneAsl]          NVARCHAR (35) NOT NULL,
    [TimestampUltimaModifica] DATETIME      NOT NULL,
    CONSTRAINT [PK_DizionariLhaAsl] PRIMARY KEY CLUSTERED ([CodiceRegione] ASC, [CodiceAsl] ASC) WITH (FILLFACTOR = 95)
);


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionariLhaAsl] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionariLhaAsl] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionariLhaAsl] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionariLhaAsl] TO [DataAccessSSIS]
    AS [dbo];

