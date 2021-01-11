CREATE TYPE [dbo].[AnnoNumero] AS TABLE (
    [Anno]   INT NULL,
    [Numero] INT NULL);


GO
GRANT EXECUTE
    ON TYPE::[dbo].[AnnoNumero] TO [DataAccessWs];

