CREATE TABLE [dbo].[TracciaAccessi_Storico] (
    [Id]                         UNIQUEIDENTIFIER NOT NULL,
    [Data]                       DATETIME         NOT NULL,
    [UtenteRichiedente]          VARCHAR (100)    NULL,
    [NomeRichiedente]            VARCHAR (100)    NULL,
    [IdUtenteRichiedente]        UNIQUEIDENTIFIER NULL,
    [IdPazienti]                 UNIQUEIDENTIFIER NOT NULL,
    [Operazione]                 VARCHAR (200)    NULL,
    [NomeHostRichiedente]        VARCHAR (50)     NULL,
    [IndirizzoIPHostRichiedente] VARCHAR (50)     NULL,
    [IdReferti]                  UNIQUEIDENTIFIER NULL,
    [IdRicoveri]                 UNIQUEIDENTIFIER NULL,
    [IdEventi]                   UNIQUEIDENTIFIER NULL,
    [IdEsterno]                  VARCHAR (64)     NULL,
    [RuoloUtenteCodice]          VARCHAR (16)     NULL,
    [RuoloUtenteDescrizione]     VARCHAR (128)    NULL,
    [MotivoAccesso]              VARCHAR (128)    NULL,
    [Note]                       VARCHAR (254)    NULL,
    [NumeroRecord]               INT              NULL,
    [ConsensoPaziente]           VARCHAR (64)     NULL,
    [IdNotaAnamnestica]          UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TracciaAccessi_Storico] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);






GO
CREATE CLUSTERED INDEX [IX_TracciaAccessi_Data]
    ON [dbo].[TracciaAccessi_Storico]([Data] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_TracciaAccessi_IdPazienti_Data_Operazione]
    ON [dbo].[TracciaAccessi_Storico]([IdPazienti] ASC, [Data] ASC, [Operazione] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Operazione_Data]
    ON [dbo].[TracciaAccessi_Storico]([Operazione] ASC, [Data] ASC);

