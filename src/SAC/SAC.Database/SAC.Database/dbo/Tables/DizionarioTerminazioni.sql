CREATE TABLE [dbo].[DizionarioTerminazioni] (
    [Codice]      VARCHAR (8)  NOT NULL,
    [Descrizione] VARCHAR (64) NULL,
    CONSTRAINT [PK_DizionarioTerminazioni] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);


GO
GRANT ALTER
    ON OBJECT::[dbo].[DizionarioTerminazioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionarioTerminazioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionarioTerminazioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioTerminazioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionarioTerminazioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[DizionarioTerminazioni] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionarioTerminazioni] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionarioTerminazioni] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioTerminazioni] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionarioTerminazioni] TO [DataAccessSISS]
    AS [dbo];

