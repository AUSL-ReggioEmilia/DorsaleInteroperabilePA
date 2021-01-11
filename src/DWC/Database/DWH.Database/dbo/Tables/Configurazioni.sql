CREATE TABLE [dbo].[Configurazioni] (
    [Sessione]       VARCHAR (128)  NOT NULL,
    [Chiave]         VARCHAR (64)   NOT NULL,
    [Descrizione]    VARCHAR (128)  NULL,
    [ValoreString]   VARCHAR (1024) NULL,
    [ValoreInt]      INT            NULL,
    [ValoreDateTime] DATETIME       NULL,
    CONSTRAINT [PK_Configurazioni] PRIMARY KEY CLUSTERED ([Sessione] ASC, [Chiave] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [CK_VoloreNonVuoto] CHECK (NOT ([ValoreString] IS NULL AND [ValoreInt] IS NULL AND [ValoreDateTime] IS NULL))
);

