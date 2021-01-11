CREATE TABLE [organigramma].[Regimi] (
    [Codice]      VARCHAR (16)  NOT NULL,
    [Descrizione] VARCHAR (128) NOT NULL,
    [Ordine]      TINYINT       CONSTRAINT [DF_Regimi_Ordine] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Regimi] PRIMARY KEY NONCLUSTERED ([Codice] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [IXU_Regimi]
    ON [organigramma].[Regimi]([Ordine] ASC, [Codice] ASC, [Descrizione] ASC);

