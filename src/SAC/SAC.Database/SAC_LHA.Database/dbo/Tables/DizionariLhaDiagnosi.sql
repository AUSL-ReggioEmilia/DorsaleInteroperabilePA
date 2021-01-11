CREATE TABLE [dbo].[DizionariLhaDiagnosi] (
    [CodiceEsenzione]         NVARCHAR (12)  NOT NULL,
    [CodiceDiagnosi]          NVARCHAR (8)   NOT NULL,
    [CodiceTestoEsenzione]    NVARCHAR (30)  NULL,
    [DescrizioneDiagnosi]     NVARCHAR (400) NULL,
    [TimestampUltimaModifica] DATETIME       NOT NULL,
    CONSTRAINT [PK_DizionariLhaDiagnosi] PRIMARY KEY CLUSTERED ([CodiceEsenzione] ASC, [CodiceDiagnosi] ASC) WITH (FILLFACTOR = 95)
);


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionariLhaDiagnosi] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionariLhaDiagnosi] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionariLhaDiagnosi] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionariLhaDiagnosi] TO [DataAccessSSIS]
    AS [dbo];

