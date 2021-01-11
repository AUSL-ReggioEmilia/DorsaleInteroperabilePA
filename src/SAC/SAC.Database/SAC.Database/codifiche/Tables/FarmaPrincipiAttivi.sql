CREATE TABLE [codifiche].[FarmaPrincipiAttivi] (
    [Id]                UNIQUEIDENTIFIER CONSTRAINT [DF_FarmaPrincipiAttivi_Id] DEFAULT (newsequentialid()) NOT NULL,
    [Codice]            INT              NOT NULL,
    [Descrizione]       VARCHAR (256)    NULL,
    [ATCCorrelati]      VARCHAR (70)     NULL,
    [Veterinario]       CHAR (1)         NULL,
    [ScadenzaBrevetto]  DATE             NULL,
    [PABase]            VARCHAR (6)      NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_FarmaPrincipiAttivi_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME         CONSTRAINT [DF_FarmaPrincipiAttivi_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_FarmaPrincipiAttivi_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]    VARCHAR (128)    CONSTRAINT [DF_FarmaPrincipiAttivi_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_FarmaPrincipiAttivi] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO
CREATE CLUSTERED INDEX [IX_CODICE]
    ON [codifiche].[FarmaPrincipiAttivi]([Codice] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DESCRIZIONE]
    ON [codifiche].[FarmaPrincipiAttivi]([Descrizione] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PABASE]
    ON [codifiche].[FarmaPrincipiAttivi]([PABase] ASC) WHERE ([PABASE] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_ATCCORRELATI]
    ON [codifiche].[FarmaPrincipiAttivi]([ATCCorrelati] ASC) WHERE ([ATCCORRELATI] IS NOT NULL);

