

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-10-29
-- Modify date: 2016-08-10 Sandro: Tabella split data e attributi senza campo XML
--									Usa tabella PrescrizioneBase
-- Description:	Ritorna la copia di KEY Id + DataPartizione dall' IdEsterno
-- =============================================
CREATE FUNCTION [dbo].[GetPrescrizioniPk] (@IdEsterno AS varchar(64))  
RETURNS TABLE 
AS
RETURN 
(
	--Per effetto del partizionamento non esiste una vera UNIQUE su IdEsterno
	--	per qui ritornerà l'ultimo in ordine di DataPartizione

	SELECT TOP 1 ID, DataPartizione, DataModificaEsterno
	FROM [store].[PrescrizioniBase]  WITH(NOLOCK)
		WHERE IDEsterno = RTRIM(@IdEsterno)
		ORDER BY DataPartizione DESC
)