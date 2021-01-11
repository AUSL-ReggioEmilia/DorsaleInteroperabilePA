CREATE TABLE [dbo].[DizionariLhaDistretti] (
    [CodiceDistretto]         NVARCHAR (5)  NOT NULL,
    [DescrizioneDistretto]    NVARCHAR (35) NOT NULL,
    [TimestampUltimaModifica] DATETIME      NOT NULL,
    CONSTRAINT [PK_DizionariLhaDistretti] PRIMARY KEY CLUSTERED ([CodiceDistretto] ASC) WITH (FILLFACTOR = 95)
);


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionariLhaDistretti] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionariLhaDistretti] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionariLhaDistretti] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionariLhaDistretti] TO [DataAccessSSIS]
    AS [dbo];

