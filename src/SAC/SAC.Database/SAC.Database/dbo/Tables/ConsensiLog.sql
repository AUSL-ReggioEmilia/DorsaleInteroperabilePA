CREATE TABLE [dbo].[ConsensiLog] (
    [Id]                          UNIQUEIDENTIFIER CONSTRAINT [DF_ConsensiLog_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [DataOperazione]              DATETIME         NOT NULL,
    [UtenteOperazione]            VARCHAR (128)    NOT NULL,
    [MotivoOperazione]            VARCHAR (1024)   NOT NULL,
    [DataInserimento]             DATETIME         NOT NULL,
    [DataDisattivazione]          DATETIME         NULL,
    [Disattivato]                 TINYINT          NOT NULL,
    [Provenienza]                 VARCHAR (16)     NOT NULL,
    [IdProvenienza]               VARCHAR (64)     NOT NULL,
    [IdPaziente]                  UNIQUEIDENTIFIER NOT NULL,
    [IdTipo]                      TINYINT          NOT NULL,
    [DataStato]                   DATETIME         NOT NULL,
    [Stato]                       BIT              NOT NULL,
    [OperatoreId]                 VARCHAR (64)     NULL,
    [OperatoreCognome]            VARCHAR (64)     NULL,
    [OperatoreNome]               VARCHAR (64)     NULL,
    [OperatoreComputer]           VARCHAR (64)     NULL,
    [PazienteProvenienza]         VARCHAR (16)     NULL,
    [PazienteIdProvenienza]       VARCHAR (64)     NULL,
    [PazienteCognome]             VARCHAR (64)     NULL,
    [PazienteNome]                VARCHAR (64)     NULL,
    [PazienteCodiceFiscale]       VARCHAR (16)     NULL,
    [PazienteDataNascita]         DATETIME         NULL,
    [PazienteComuneNascitaCodice] VARCHAR (6)      NULL,
    [PazienteNazionalitaCodice]   VARCHAR (3)      NULL,
    [PazienteTessera]             VARCHAR (16)     NULL,
    [MetodoAssociazione]          VARCHAR (32)     NULL,
    CONSTRAINT [PK_ConsensiLog] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE CLUSTERED INDEX [IX_ConsensiLog_IdPaziente]
    ON [dbo].[ConsensiLog]([IdPaziente] ASC, [DataStato] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_ConsensiLog_Esterno]
    ON [dbo].[ConsensiLog]([Provenienza] ASC, [IdProvenienza] ASC, [DataDisattivazione] ASC) WITH (FILLFACTOR = 95);

