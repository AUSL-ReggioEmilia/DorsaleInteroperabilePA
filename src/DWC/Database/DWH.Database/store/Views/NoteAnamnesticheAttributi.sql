


-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-24
-- Description:	Vista che raggruppa le tabelle degli store
-- =============================================
CREATE VIEW [store].[NoteAnamnesticheAttributi]
AS
	SELECT *
	FROM dbo.NoteAnamnesticheAttributi_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.NoteAnamnesticheAttributi_Recent