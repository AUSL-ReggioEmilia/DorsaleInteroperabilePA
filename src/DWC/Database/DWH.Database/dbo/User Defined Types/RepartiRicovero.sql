CREATE TYPE [dbo].[RepartiRicovero] AS TABLE (
    [Azienda] VARCHAR (16) NULL,
    [Codice]  VARCHAR (16) NULL);


GO
GRANT EXECUTE
    ON TYPE::[dbo].[RepartiRicovero] TO [ExecuteFrontEnd];


GO
GRANT EXECUTE
    ON TYPE::[dbo].[RepartiRicovero] TO [ExecuteWs];

