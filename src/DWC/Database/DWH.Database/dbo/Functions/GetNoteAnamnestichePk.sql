


-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-30 - Copiata dalla dbo.GetPrescrizioniPk
-- Description:	Ritorna la copia di KEY Id + DataPartizione dall' IdEsterno
-- =============================================
CREATE FUNCTION [dbo].[GetNoteAnamnestichePk] (@IdEsterno AS varchar(64))  
RETURNS TABLE 
AS
RETURN 
(
	--Per effetto del partizionamento non esiste una vera UNIQUE su IdEsterno
	--	per qui ritornerà l'ultimo in ordine di DataPartizione

	SELECT TOP 1 ID, DataPartizione, DataModificaEsterno
	FROM [store].[NoteAnamnesticheBase]  WITH(NOLOCK)
		WHERE IDEsterno = RTRIM(@IdEsterno)
		ORDER BY DataPartizione DESC
)