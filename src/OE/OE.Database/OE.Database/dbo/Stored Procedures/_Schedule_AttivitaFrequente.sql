CREATE PROCEDURE [dbo].[_Schedule_AttivitaFrequente]
AS
BEGIN
	SET NOCOUNT ON

	EXEC [dbo].[Maintenance_SyncOrganigramma]

	EXEC [dbo].[Maintenance_CacheGruppiUtente]
END