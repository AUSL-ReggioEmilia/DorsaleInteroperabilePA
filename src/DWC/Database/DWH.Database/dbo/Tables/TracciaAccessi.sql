CREATE TABLE [dbo].[TracciaAccessi] (
    [Id]                         UNIQUEIDENTIFIER CONSTRAINT [DF_ConsensiStorico_Id] DEFAULT (newid()) NOT NULL,
    [Data]                       DATETIME         CONSTRAINT [DF_ConsensiStorico_Data] DEFAULT (getdate()) NOT NULL,
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
    CONSTRAINT [PK_TracciaAccessi] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);






GO
CREATE CLUSTERED INDEX [IX_TracciaAccessi_Data]
    ON [dbo].[TracciaAccessi]([Data] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_TracciaAccessi_IdPazienti_Data_Operazione]
    ON [dbo].[TracciaAccessi]([IdPazienti] ASC, [Data] ASC, [Operazione] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Username di Windows che ha effettuato l''aggiornamento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TracciaAccessi', @level2type = N'COLUMN', @level2name = N'UtenteRichiedente';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nome dell''utente che ha effettuato l''aggiornamento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TracciaAccessi', @level2type = N'COLUMN', @level2name = N'NomeRichiedente';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID dell''utente (AD) che ha effettuato l''aggiornamento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TracciaAccessi', @level2type = N'COLUMN', @level2name = N'IdUtenteRichiedente';


GO
CREATE NONCLUSTERED INDEX [IX_Operazione_Data]
    ON [dbo].[TracciaAccessi]([Operazione] ASC, [Data] ASC);

