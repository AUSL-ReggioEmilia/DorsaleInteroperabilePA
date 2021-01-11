CREATE TABLE [dbo].[AppCn_AnagrafeEsenti] (
    [IdPersona]               NUMERIC (10)  NULL,
    [CodiceEsenzione]         NVARCHAR (12) NULL,
    [DescrizioneEsenzione]    NVARCHAR (35) NULL,
    [CodiceDiagnosi]          NVARCHAR (8)  NULL,
    [DataInizioValidita]      DATETIME      NULL,
    [DataFineValidita]        DATETIME      NULL,
    [NumeroAutorizzazione]    NUMERIC (7)   NULL,
    [TimestampUltimaModifica] DATETIME      NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_AppCn_AnagrafeEsenti_IdPersona]
    ON [dbo].[AppCn_AnagrafeEsenti]([IdPersona] ASC) WITH (FILLFACTOR = 95);

