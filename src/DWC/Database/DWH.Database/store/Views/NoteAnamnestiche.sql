


-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-24
-- Description:	Vista che raggruppa le tabelle degli store
-- =============================================
CREATE VIEW [store].[NoteAnamnestiche]
AS
	SELECT *
	FROM dbo.NoteAnamnestiche_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.NoteAnamnestiche_Recent