

CREATE VIEW [dbo].[DatabaseLogTsql]
AS
	SELECT [DatabaseLogID]
		  ,[PostTime]
		  ,[DatabaseUser]
		  ,[Event]
		  ,[Schema]
		  ,[Object]
		  ,[XmlEvent].value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)') AS [TSQL]
	FROM [dbo].[DatabaseLog]
	WHERE LoginName != 'NT AUTHORITY\SYSTEM'