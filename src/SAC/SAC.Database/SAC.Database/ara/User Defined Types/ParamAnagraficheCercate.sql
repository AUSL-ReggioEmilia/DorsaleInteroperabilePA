CREATE TYPE [ara].[ParamAnagraficheCercate] AS TABLE (
    [IdProvenienza] VARCHAR (64)    NULL,
    [Risposta]      VARBINARY (MAX) NULL);


GO
GRANT EXECUTE
    ON TYPE::[ara].[ParamAnagraficheCercate] TO [DataAccessWs];

