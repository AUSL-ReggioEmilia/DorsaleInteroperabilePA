-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2015-05-22
-- Description:	Restituisce gli ultimi accessi al paziente
-- Modify date: 2015-10-28 Stefano P: Aggiunto campo Note
-- =============================================
CREATE PROCEDURE [frontend].[PazientiAccessiLista] 
(	
	@IdPaziente UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsPazientiAccessiLista2

	L'interfaccia passa alla SP che traccia gli accessi o Cognome, Nome dell'utente loggato 
	oppure la costante "Utente Tecnico", quindi nel campo TracciaAccessi.NomeRichiedente c'è già
	il nome da visualizzare
*/
	SET NOCOUNT ON;
	--
	-- Calcolo la data minima da utilizzare
	--
	DECLARE @DataAccessoMin DATETIME
	DECLARE @DataAccessoDa DATETIME
	-- Data minima da cui estrarre gli accessi (per questioni normative)
	SET @DataAccessoMin = '2013-07-10'
	
	SET @DataAccessoDa = DATEADD(month, - 12, GETDATE())
	IF @DataAccessoDa < @DataAccessoMin
		SET @DataAccessoDa = @DataAccessoMin
	--
	-- Restituisco gli ultimi N accessi (N=10)
	--
	SELECT 
		CONVERT(Datetime, CONVERT(VARCHAR(16), DataDiAccesso, 120), 120) AS DataDiAccesso
		, Utente
		, MotivoAccesso		
		, Note
	FROM 
		(
			--
			-- Restituisco gli ultimi N accessi (N=10)
			--
			SELECT TOP 10
				    T.Data AS DataDiAccesso
				  , T.NomeRichiedente AS Utente
				  , T.MotivoAccesso
				  , T.Note
			FROM 
				TracciaAccessi AS T 
			INNER JOIN dbo.GetPazientiDaCercareByIdSac(@IdPaziente) AS P
				ON T.IdPazienti = P.Id
			WHERE
				T.Data >= @DataAccessoDa
			ORDER BY 
				T.Data DESC	
		) AS Accessi
	GROUP BY 
		CONVERT(Datetime, CONVERT(VARCHAR(16), DataDiAccesso, 120), 120)
		, Utente
		, MotivoAccesso
		, Note
		
	ORDER BY 1 DESC --order by sul primo campo
	
END


