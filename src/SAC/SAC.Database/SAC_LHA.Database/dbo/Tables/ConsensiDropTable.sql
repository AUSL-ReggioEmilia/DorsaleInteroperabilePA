CREATE TABLE [dbo].[ConsensiDropTable] (
    [Operazione]                  TINYINT      NOT NULL,
    [Id]                          VARCHAR (64) NULL,
    [Tipo]                        VARCHAR (64) NOT NULL,
    [DataStato]                   DATETIME     NOT NULL,
    [Stato]                       BIT          NOT NULL,
    [OperatoreId]                 VARCHAR (64) NULL,
    [OperatoreCognome]            VARCHAR (64) NULL,
    [OperatoreNome]               VARCHAR (64) NULL,
    [OperatoreComputer]           VARCHAR (64) NULL,
    [PazienteProvenienza]         VARCHAR (16) NULL,
    [PazienteProvenienzaId]       VARCHAR (64) NULL,
    [PazienteCognome]             VARCHAR (64) NULL,
    [PazienteNome]                VARCHAR (64) NULL,
    [PazienteCodiceFiscale]       VARCHAR (16) NULL,
    [PazienteDataNascita]         DATETIME     NULL,
    [PazienteComuneNascitaCodice] VARCHAR (6)  NULL,
    [PazienteNazionalitaCodice]   VARCHAR (3)  NULL,
    [PazienteTessera]             VARCHAR (16) NULL,
    [DataInserimento]             DATETIME     CONSTRAINT [DF_ConsensiDropTable_DataInserimento] DEFAULT (getdate()) NULL,
    [DataElaborazione]            DATETIME     NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_ConsensiDropTable_DataElaborazione]
    ON [dbo].[ConsensiDropTable]([DataElaborazione] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_ConsensiDropTable_Id]
    ON [dbo].[ConsensiDropTable]([Id] ASC) WITH (FILLFACTOR = 95);

