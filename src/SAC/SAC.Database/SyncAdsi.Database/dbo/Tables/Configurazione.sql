CREATE TABLE [dbo].[Configurazione] (
    [Nome]   VARCHAR (64)   NOT NULL,
    [Valore] VARCHAR (1024) NULL,
    CONSTRAINT [PK_Configurazione] PRIMARY KEY CLUSTERED ([Nome] ASC)
);

