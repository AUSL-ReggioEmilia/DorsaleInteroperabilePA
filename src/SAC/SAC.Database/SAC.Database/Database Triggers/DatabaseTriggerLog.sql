
CREATE TRIGGER [DatabaseTriggerLog] ON DATABASE 
	FOR DDL_DATABASE_LEVEL_EVENTS AS 
BEGIN
	SET NOCOUNT ON;
	SET ANSI_PADDING ON;
	
	DECLARE @data XML;
	DECLARE @schema sysname;
	DECLARE @object sysname;
	DECLARE @eventType sysname;
	DECLARE @LoginName sysname;
	
	SET @data = EVENTDATA();
	SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'sysname');
	SET @schema = @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname');
	SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname')
	SET @LoginName = @data.value('(/EVENT_INSTANCE/LoginName)[1]', 'sysname')
	
	IF @object IS NOT NULL
		PRINT '  ' + @eventType + ' - ' + @schema + '.' + @object;
	ELSE
		PRINT '  ' + @eventType + ' - ' + @schema;
		
	IF @eventType IS NULL
		PRINT CONVERT(nvarchar(max), @data);
		
	INSERT [dbo].[DatabaseLog] 
		(
		[PostTime], 
		[DatabaseUser], 
		[LoginName], 
		[Event], 
		[Schema], 
		[Object], 
		[XmlEvent]
		) 
	VALUES 
		(
		GETDATE(), 
		CONVERT(sysname, CURRENT_USER),
		@LoginName, 
		@eventType, 
		CONVERT(sysname, @schema), 
		CONVERT(sysname, @object), 
		@data
		);
END;



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Database trigger to audit all of the DDL changes made to the AdventureWorks database.', @level0type = N'TRIGGER', @level0name = N'DatabaseTriggerLog';

