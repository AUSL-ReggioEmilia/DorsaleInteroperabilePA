CREATE TABLE [dbo].[DizionarioCircoscrizioni] (
    [SubComuneDom] VARCHAR (64) NULL,
    [SubComuneRes] VARCHAR (64) NULL
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioCircoscrizioni] TO [DataAccessSql]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[DizionarioCircoscrizioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionarioCircoscrizioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionarioCircoscrizioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioCircoscrizioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionarioCircoscrizioni] TO [DataAccessDizionari]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[DizionarioCircoscrizioni] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionarioCircoscrizioni] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionarioCircoscrizioni] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioCircoscrizioni] TO [DataAccessSISS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionarioCircoscrizioni] TO [DataAccessSISS]
    AS [dbo];

