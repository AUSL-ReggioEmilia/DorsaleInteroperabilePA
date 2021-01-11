CREATE TABLE [dbo].[AppCn_Fusioni] (
    [IdVittima]                NUMERIC (10)  NULL,
    [CognomeVittima]           NVARCHAR (40) NULL,
    [NomeVittima]              NVARCHAR (40) NULL,
    [DataNascitaVittima]       DATETIME      NULL,
    [CodiceFiscaleVittima]     NVARCHAR (16) NULL,
    [TesseraSanitariaVittima]  NVARCHAR (16) NULL,
    [IdVincente]               NUMERIC (10)  NULL,
    [CognomeVincente]          NVARCHAR (40) NULL,
    [NomeVincente]             NVARCHAR (40) NULL,
    [DataNascitaVincente]      DATETIME      NULL,
    [CodiceFiscaleVincente]    NVARCHAR (16) NULL,
    [TesseraSanitariaVincente] NVARCHAR (16) NULL,
    [TimestampFusione]         DATETIME      NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_AppCn_Fusioni_IdVincente]
    ON [dbo].[AppCn_Fusioni]([IdVincente] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_AppCn_Fusioni_IdVittima]
    ON [dbo].[AppCn_Fusioni]([IdVittima] ASC) WITH (FILLFACTOR = 95);

