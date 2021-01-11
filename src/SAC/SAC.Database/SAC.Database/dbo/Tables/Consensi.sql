CREATE TABLE [dbo].[Consensi] (
    [Id]                          UNIQUEIDENTIFIER CONSTRAINT [DF_Consensi_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [DataInserimento]             DATETIME         CONSTRAINT [DF_Consensi_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataDisattivazione]          DATETIME         NULL,
    [Disattivato]                 TINYINT          CONSTRAINT [DF_Consensi_Disattivato] DEFAULT ((0)) NOT NULL,
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
    [Attributi]                   XML              NULL,
    CONSTRAINT [PK_Consensi] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_Consensi_ConsensiTipo] FOREIGN KEY ([IdTipo]) REFERENCES [dbo].[ConsensiTipo] ([Id]),
    CONSTRAINT [FK_Consensi_Pazienti] FOREIGN KEY ([IdPaziente]) REFERENCES [dbo].[Pazienti] ([Id]),
    CONSTRAINT [FK_Consensi_Provenienze] FOREIGN KEY ([Provenienza]) REFERENCES [dbo].[Provenienze] ([Provenienza])
);






GO
CREATE CLUSTERED INDEX [IX_Consensi_IdPaziente]
    ON [dbo].[Consensi]([IdPaziente] ASC, [DataStato] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Consensi_Esterno]
    ON [dbo].[Consensi]([Provenienza] ASC, [IdProvenienza] ASC, [DataDisattivazione] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Consensi_Aggregazione]
    ON [dbo].[Consensi]([Disattivato] ASC, [IdPaziente] ASC, [DataStato] ASC, [DataInserimento] ASC, [IdTipo] ASC);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Attivo; 1=Cancellato;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Consensi', @level2type = N'COLUMN', @level2name = N'Disattivato';

