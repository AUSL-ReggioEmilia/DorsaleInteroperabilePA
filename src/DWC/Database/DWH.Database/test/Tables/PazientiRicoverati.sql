CREATE TABLE [test].[PazientiRicoverati] (
    [IdPaziente]           UNIQUEIDENTIFIER NOT NULL,
    [Cognome]              VARCHAR (64)     NULL,
    [Nome]                 VARCHAR (64)     NULL,
    [DataNascita]          DATETIME         NULL,
    [CodiceFiscale]        VARCHAR (16)     NULL,
    [IdRicovero]           UNIQUEIDENTIFIER NOT NULL,
    [DataModificaRicovero] DATETIME         NOT NULL,
    [NumeroNosologico]     VARCHAR (64)     NOT NULL,
    [AziendaErogante]      VARCHAR (64)     NOT NULL,
    [TipoRicoveroCodice]   VARCHAR (16)     NULL,
    [StatoRicoveroCodice]  TINYINT          NOT NULL,
    [UltimoRepartoCodice]  VARCHAR (16)     NULL,
    [IdEvento]             UNIQUEIDENTIFIER NOT NULL,
    [DataModificaEvento]   DATETIME         NOT NULL,
    [TipoEventoCodice]     VARCHAR (16)     NOT NULL,
    [EventoRepartoCodice]  VARCHAR (16)     NULL,
    [DataEvento]           DATETIME         NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PazientiRicoverati]
    ON [test].[PazientiRicoverati]([IdEvento] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Nosologico]
    ON [test].[PazientiRicoverati]([NumeroNosologico] ASC, [AziendaErogante] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiRicoverati_Ev2]
    ON [test].[PazientiRicoverati]([TipoEventoCodice] ASC, [TipoRicoveroCodice] ASC, [EventoRepartoCodice] ASC, [DataEvento] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiRicoverati_Ev1]
    ON [test].[PazientiRicoverati]([Cognome] ASC, [Nome] ASC, [TipoEventoCodice] ASC, [TipoRicoveroCodice] ASC, [EventoRepartoCodice] ASC, [DataEvento] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiRicoverati_Ric2]
    ON [test].[PazientiRicoverati]([UltimoRepartoCodice] ASC, [TipoRicoveroCodice] ASC, [StatoRicoveroCodice] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiRicoverati_Ric1]
    ON [test].[PazientiRicoverati]([Cognome] ASC, [Nome] ASC, [UltimoRepartoCodice] ASC, [TipoRicoveroCodice] ASC, [StatoRicoveroCodice] ASC);


GO
CREATE CLUSTERED INDEX [IX_IdPaziente]
    ON [test].[PazientiRicoverati]([IdPaziente] ASC);

