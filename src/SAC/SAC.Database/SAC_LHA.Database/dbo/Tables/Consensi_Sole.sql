CREATE TABLE [dbo].[Consensi_Sole] (
    [Id_Persona]  NUMERIC (10) NULL,
    [Codice_Sole] NVARCHAR (1) NULL,
    [Data_Inizio] DATETIME     NULL,
    [Data_Fine]   DATETIME     NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Consensi]
    ON [dbo].[Consensi_Sole]([Id_Persona] ASC, [Codice_Sole] ASC) WITH (FILLFACTOR = 95);

