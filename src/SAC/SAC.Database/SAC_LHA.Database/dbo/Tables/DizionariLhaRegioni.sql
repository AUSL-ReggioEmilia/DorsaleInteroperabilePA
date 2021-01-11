CREATE TABLE [dbo].[DizionariLhaRegioni] (
    [CodiceRegione]           VARCHAR (3)   NOT NULL,
    [DescrizioneRegione]      NVARCHAR (35) NOT NULL,
    [TimestampUltimaModifica] DATETIME      NOT NULL,
    CONSTRAINT [PK_DizionariLhaRegioni] PRIMARY KEY CLUSTERED ([CodiceRegione] ASC) WITH (FILLFACTOR = 95)
);


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionariLhaRegioni] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionariLhaRegioni] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionariLhaRegioni] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionariLhaRegioni] TO [DataAccessSSIS]
    AS [dbo];

