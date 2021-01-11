
-- =============================================
-- Author:		Ettore
-- Create date: 2013-05-17
-- Modify date: 2016-05-11 sandro - Usa nuovo campo
-- Description:	Ottiene la Consenso minimo 
-- =============================================
CREATE FUNCTION [dbo].[GetPazientiConsensoMinimo]  
(
	@IdPaziente UNIQUEIDENTIFIER
)
RETURNS TINYINT
AS
BEGIN
/*
	CREATA DA ETTORE 2014-09-25: la funzione viene usata per identificare l'immagine da visualizzare per il consenso nelle liste pazienti
		I valori restituiti sono:
		---------------------------------------------------
		Dossier Dossier	Generico	IdImmagine	Descrizione
		Storico	
		---------------------------------------------------
		0		0		0	 		0			NESSUN CONSENSO
		0		0		1	 		1			CONSENSO GENERICO
		0		1		1	 		2			CONSENSO DOSSIER
		1		1		1	 		3			CONSENSO DOSSIERSTORICO
		---------------------------------------------------
		Le altre combinazioni non sono permesse
		---------------------------------------------------
*/
	DECLARE @Ret tinyint

	SELECT TOP 1 @Ret = [ConsensoAziendaleCodice]
			FROM [sac].[Pazienti] AS P
			WHERE P.Id = @IdPaziente

	RETURN ISNULL(@Ret, 0)
END


