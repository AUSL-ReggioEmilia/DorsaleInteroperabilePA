


CREATE VIEW [store].[NoteAnamnesticheBase]
AS
	SELECT *
	FROM dbo.NoteAnamnesticheBase_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.NoteAnamnesticheBase_Recent