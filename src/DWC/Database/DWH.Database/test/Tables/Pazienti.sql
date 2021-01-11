CREATE TABLE [test].[Pazienti] (
    [IdPaziente]    UNIQUEIDENTIFIER NOT NULL,
    [Cognome]       VARCHAR (64)     NULL,
    [Nome]          VARCHAR (64)     NULL,
    [DataNascita]   DATETIME         NULL,
    [CodiceFiscale] VARCHAR (16)     NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiRicoverati_Cognome_Nome]
    ON [test].[Pazienti]([Cognome] ASC, [Nome] ASC);


GO
CREATE CLUSTERED INDEX [IX_IdPaziente]
    ON [test].[Pazienti]([IdPaziente] ASC);

