


--- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-02
-- Description:	Ritorna la copia di KEY Id + DataPartizione dall' IdEsterno
-- ModifyDate:	2017-03-07 Ettore: uso la vista store.RefertiBase altrimenti si verificano errori 
--				in caso di aggiornamento di un referto "cancellato"
-- =============================================
CREATE FUNCTION [dbo].[GetRefertiPk] (@IdEsterno AS varchar(64))  
RETURNS 
@Ret TABLE 
(
	ID UNIQUEIDENTIFIER, DataPartizione SMALLDATETIME
)
AS
BEGIN
	--Per effetto del partizionamento non esiste una vera UNIQUE su IdEsterno
	--	per qui ritornerà l'ultimo in ordine di DataPartizione
	-- Usa  WITH(NOLOCK) per evitare deaded lock se usata su Allegati e Prestazioni
	
	INSERT INTO @Ret (ID, DataPartizione)
	SELECT TOP 1 ID, DataPartizione
	FROM [store].[RefertiBase] WITH(NOLOCK)
		WHERE IDEsterno = RTRIM(@IdEsterno)
		ORDER BY DataPartizione DESC

	-- Se non trovato cerca nei riferimenti
	IF NOT EXISTS( SELECT * FROM @Ret)
		INSERT INTO @Ret (ID, DataPartizione)
		SELECT TOP 1 IdRefertiBase, DataPartizione
		FROM [store].[RefertiBaseRiferimenti] WITH(NOLOCK) 
		WHERE IDEsterno = RTRIM(@IdEsterno)
		ORDER BY DataPartizione DESC

	RETURN 
END