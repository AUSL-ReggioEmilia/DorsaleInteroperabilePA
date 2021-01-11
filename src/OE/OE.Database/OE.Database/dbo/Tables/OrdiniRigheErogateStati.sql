CREATE TABLE [dbo].[OrdiniRigheErogateStati] (
    [Codice]      VARCHAR (16)  NOT NULL,
    [Descrizione] VARCHAR (128) NOT NULL,
    [Ordinamento] TINYINT       NOT NULL,
    CONSTRAINT [PK_OrdiniRigheErogateStati] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);

