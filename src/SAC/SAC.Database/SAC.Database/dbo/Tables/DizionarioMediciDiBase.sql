CREATE TABLE [dbo].[DizionarioMediciDiBase] (
    [Codice]        INT           NOT NULL,
    [CodiceFiscale] VARCHAR (16)  NULL,
    [CognomeNome]   VARCHAR (128) NULL,
    [Distretto]     VARCHAR (8)   NULL,
    CONSTRAINT [PK_DizionarioMediciDiBase] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);


GO
GRANT ALTER
    ON OBJECT::[dbo].[DizionarioMediciDiBase] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionarioMediciDiBase] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionarioMediciDiBase] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioMediciDiBase] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionarioMediciDiBase] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[DizionarioMediciDiBase] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionarioMediciDiBase] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionarioMediciDiBase] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioMediciDiBase] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionarioMediciDiBase] TO [DataAccessSISS]
    AS [dbo];

