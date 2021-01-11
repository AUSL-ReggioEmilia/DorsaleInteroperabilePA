

-- =============================================
-- Author:		ETTORE
-- Create date: 2017-12-13
-- Description:	Ritorna la descrizione dello stato della nota anamnestica (derivata da quella dei referti)
-- =============================================
CREATE FUNCTION [dbo].[GetNotaAnamnesticaStatoDesc] 
(
	@StatoCodice AS TINYINT 
	, @StatoDesc AS VARCHAR(128)=NULL
)  
RETURNS VARCHAR(128) AS  
/*
@StatoCodice =
	0 = In corso
	1 = Completata
	2 = Variata dopo il completamento
	3 = Cancellata
*/
BEGIN 

	DECLARE @Ret AS VARCHAR(128)

	IF ISNULL(@StatoDesc, '') = ''
		BEGIN
		--
		-- Non c'è, la calcolo
		--
		SET @Ret = CASE @StatoCodice	WHEN '0' THEN 'In corso'
							WHEN '1' THEN 'Completata'
							WHEN '2' THEN 'Variata'
							WHEN '3' THEN 'Cancellata'
							ELSE '' END	
		END
	ELSE
		BEGIN
		--
		-- Valorizzo con la desc passata
		--
		SET @Ret = @StatoDesc
		END
	--
	-- Restituisco
	--
	RETURN @Ret

END