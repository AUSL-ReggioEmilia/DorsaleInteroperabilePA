CREATE TABLE [dbo].[DizionariLhaFasceReddito] (
    [Codice]      NVARCHAR (12) NOT NULL,
    [Descrizione] NVARCHAR (35) NOT NULL,
    CONSTRAINT [PK_DizionariLhaFasceReddito] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);

