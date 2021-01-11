CREATE TABLE [dbo].[DizionarioEsenzioni] (
    [CodiceEsenzione]             VARCHAR (32)   NULL,
    [CodiceDiagnosi]              VARCHAR (32)   NULL,
    [Patologica]                  BIT            NULL,
    [TestoEsenzione]              VARCHAR (2048) NULL,
    [DecodificaEsenzioneDiagnosi] VARCHAR (1024) NULL
);


GO
GRANT ALTER
    ON OBJECT::[dbo].[DizionarioEsenzioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionarioEsenzioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionarioEsenzioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioEsenzioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionarioEsenzioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[DizionarioEsenzioni] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionarioEsenzioni] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionarioEsenzioni] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioEsenzioni] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionarioEsenzioni] TO [DataAccessSISS]
    AS [dbo];

