
-- =============================================
-- Author:		Ettore
-- Create date: 2015-05-22: Sostituisce la dbo.Ws2PazientiBySemplice (Restituito la DataDecesso)
--							Limitazione record restituiti
-- Modify date: 2016-07-11: Ettore - Suddivisione in query separate relative ai parametri
--										per ogni query almento un campo obbligatorio
--										altrimenti @parametro IS NULL non usa nessun indice
-- Description:	Restituisce lista di pazienti
-- =============================================
CREATE PROCEDURE [ws2].[PazientiBySemplice]
(
		@Cognome as varchar(50)=NULL,
		@Nome as varchar(50)=NULL,
		@DataNascita datetime=NULL,
		@LuogoNascita varchar(80)=NULL
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
				(Cognome LIKE @Cognome + '%')
			AND (Nome LIKE @Nome + '%'  OR NULLIF(@Nome, '') IS NULL)
			AND (LuogoNascita LIKE @LuogoNascita + '%' OR NULLIF(@LuogoNascita, '') IS NULL)
			AND (DataNascita = @DataNascita OR NULLIF(@DataNascita, '') IS NULL)
		ORDER BY  Cognome, Nome

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
		WHERE	(Cognome LIKE @Cognome + '%' OR NULLIF(@Cognome, '') IS NULL)
			AND (Nome LIKE @Nome + '%'  OR NULLIF(@Nome, '') IS NULL)
			AND (LuogoNascita LIKE @LuogoNascita + '%' OR NULLIF(@LuogoNascita, '') IS NULL)
			AND (DataNascita = @DataNascita OR NULLIF(@DataNascita, '') IS NULL)
		ORDER BY  Cognome, Nome
	END

	RETURN @@ERROR
END

