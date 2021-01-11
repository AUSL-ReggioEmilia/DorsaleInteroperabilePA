

-- =============================================
-- Author:		Ettore
-- Create date: 2015-05-22: Sostituisce la dbo.Ws2PazientiBySoundex (Restituito la DataDecesso)
--							Limitazione record restituiti
-- Modify date: 2016-07-11: Ettore - Suddivisione in query separate relative ai parametri
--										per ogni query almento un campo obbligatorio
--										altrimenti @parametro IS NULL non usa nessun indice
-- Description:	Restituisce lista di pazienti
-- =============================================
CREATE PROCEDURE [ws2].[PazientiBySoundex]
(
	@Cognome as varchar(50)=null,
	@Nome as varchar(50)=null,
	@DataNascita datetime=null,
	@LuogoNascita varchar(80)=null
)
AS
BEGIN 
	SET NOCOUNT ON

	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Pazienti') , 200)	

	IF NOT @Cognome IS NULL
	BEGIN 
		---------------------------------------------------
		--  Priorità  a Cognome
		---------------------------------------------------
		SELECT  TOP (@Top)
				Pazienti.Id,
				Pazienti.Nome,
				Pazienti.Cognome,
				Pazienti.CodiceFiscale, 
				Pazienti.DataNascita, 
				Pazienti.LuogoNascita,
				dbo.GetPazientiConsenso(Pazienti.Id) as Consenso, 
				CASE WHEN LEN(ISNULL(Pazienti.DatiAnamnestici,''))>1 THEN 1
									ELSE 0 END AS ContieneDatiAnamnestici 
				, dbo.GetPazientiDataDecesso(Pazienti.Id)  AS DataDecesso
		FROM	Pazienti
		WHERE	
			(SoundexCognome = SOUNDEX(@Cognome))
			AND (SoundexNome = SOUNDEX(@Nome) OR NULLIF(@Nome, '') IS NULL)
			AND (LuogoNascita LIKE @LuogoNascita + '%' OR NULLIF(@LuogoNascita, '') IS NULL)
			AND (DataNascita = @DataNascita OR NULLIF(@DataNascita, '') IS NULL)

		ORDER BY DIFFERENCE(Cognome, @Cognome) DESC,
				DIFFERENCE(Nome, @Nome) DESC, Cognome,Nome
	END
	ELSE
	BEGIN 
		---------------------------------------------------
		--  Per compatibilità senza filtro obbligatorio
		--		NON userà INDICI
		---------------------------------------------------
		SELECT  TOP (@Top)
				Pazienti.Id,
				Pazienti.Nome,
				Pazienti.Cognome,
				Pazienti.CodiceFiscale, 
				Pazienti.DataNascita, 
				Pazienti.LuogoNascita,
				dbo.GetPazientiConsenso(Pazienti.Id) as Consenso, 
				CASE WHEN LEN(ISNULL(Pazienti.DatiAnamnestici,''))>1 THEN 1
									ELSE 0 END AS ContieneDatiAnamnestici 
				, dbo.GetPazientiDataDecesso(Pazienti.Id)  AS DataDecesso
		FROM	Pazienti
		WHERE	
			(SoundexCognome = SOUNDEX(@Cognome)	OR NULLIF(@Cognome, '') IS NULL)
			AND (SoundexNome = SOUNDEX(@Nome) OR NULLIF(@Nome, '') IS NULL)
			AND (LuogoNascita LIKE @LuogoNascita + '%' OR NULLIF(@LuogoNascita, '') IS NULL)
			AND (DataNascita = @DataNascita OR NULLIF(@DataNascita, '') IS NULL)

		ORDER BY DIFFERENCE(Cognome, @Cognome) DESC,
				DIFFERENCE(Nome, @Nome) DESC, Cognome,Nome
	END 

	RETURN @@ERROR
END

