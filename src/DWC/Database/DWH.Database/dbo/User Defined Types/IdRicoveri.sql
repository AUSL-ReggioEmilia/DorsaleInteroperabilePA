CREATE TYPE [dbo].[IdRicoveri] AS TABLE (
    [Id] UNIQUEIDENTIFIER NULL);




GO
GRANT EXECUTE
    ON TYPE::[dbo].[IdRicoveri] TO [ExecuteWs];

