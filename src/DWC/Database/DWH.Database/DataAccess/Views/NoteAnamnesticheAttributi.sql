
-- =============================================
-- Author:		ETTORE
-- Create date: 2018-10-26
-- Description:	Nuova vista ad uso esclusivo accesso ESTERNO
--				Utilizzo vista store.NoteAnamnesticheAttributi
-- =============================================
CREATE VIEW [DataAccess].[NoteAnamnesticheAttributi] 
AS
	
	SELECT 
		IdNoteAnamnesticheBase
		, DataPartizione
		, Nome
		, Valore
	FROM 
		[store].[NoteAnamnesticheAttributi] WITH(NOLOCK)