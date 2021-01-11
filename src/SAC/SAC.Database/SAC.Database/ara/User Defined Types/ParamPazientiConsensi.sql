CREATE TYPE [ara].[ParamPazientiConsensi] AS TABLE (
    [IdProvenienza]     VARCHAR (64) NOT NULL,
    [IdTipo]            TINYINT      NOT NULL,
    [DataStato]         DATETIME     NOT NULL,
    [Stato]             BIT          NOT NULL,
    [OperatoreId]       VARCHAR (64) NULL,
    [OperatoreCognome]  VARCHAR (64) NULL,
    [OperatoreNome]     VARCHAR (64) NULL,
    [OperatoreComputer] VARCHAR (64) NULL,
    [Attributi]         XML          NULL);


GO
GRANT EXECUTE
    ON TYPE::[ara].[ParamPazientiConsensi] TO [DataAccessWs];

