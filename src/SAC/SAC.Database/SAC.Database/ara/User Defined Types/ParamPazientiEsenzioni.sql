CREATE TYPE [ara].[ParamPazientiEsenzioni] AS TABLE (
    [CodiceEsenzione]               VARCHAR (32)   NULL,
    [CodiceDiagnosi]                VARCHAR (32)   NULL,
    [Patologica]                    BIT            NULL,
    [DataInizioValidita]            DATETIME       NULL,
    [DataFineValidita]              DATETIME       NULL,
    [NumeroAutorizzazioneEsenzione] VARCHAR (64)   NULL,
    [NoteAggiuntive]                VARCHAR (2048) NULL,
    [CodiceTestoEsenzione]          VARCHAR (64)   NULL,
    [TestoEsenzione]                VARCHAR (2048) NULL,
    [DecodificaEsenzioneDiagnosi]   VARCHAR (1024) NULL,
    [AttributoEsenzioneDiagnosi]    VARCHAR (1024) NULL,
    [OperatoreId]                   VARCHAR (64)   NULL,
    [OperatoreCognome]              VARCHAR (64)   NULL,
    [OperatoreNome]                 VARCHAR (64)   NULL,
    [OperatoreComputer]             VARCHAR (64)   NULL);


GO
GRANT EXECUTE
    ON TYPE::[ara].[ParamPazientiEsenzioni] TO [DataAccessWs];

