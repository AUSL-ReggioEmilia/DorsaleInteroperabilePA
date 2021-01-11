CREATE PROCEDURE [dbo].[CoreEnnupleAccessiCheck]
@utente VARCHAR (64), @idSistemaErogante UNIQUEIDENTIFIER, @idStato TINYINT=1
AS
BEGIN
--2014-10-21 SANDRO: Il controllo sulla presenza di almeno 1 ennupla era errato
--						Non venivano caricate le ennuple con Sistema=Tutti
--						Se non configurato per ora il Defult per i READ è TRUE

DECLARE @DefaultR bit = 1
DECLARE @Default bit = 0
DECLARE @Count int = 0

	SET NOCOUNT ON;

	BEGIN TRY
	
		-- Se non ci sono ennuple, consento l'accesso
		SELECT @Count = COUNT(*) FROM EnnupleAccessi WHERE IDStato = @idStato
		IF @Count = 0
			SET @Default = 1
	
		SELECT 
			CAST(CASE 
					WHEN ISNULL(SUM(CASE
										WHEN [Not] = 0 THEN cast(R as int)
										WHEN ([Not] = 1 AND R = 1) THEN -1000
										WHEN ([Not] = 1 AND R = 0) THEN 0
									END), @DefaultR) <= 0 THEN 0 ELSE 1 
				 END as bit) R,
			CAST(CASE
					WHEN ISNULL(SUM(CASE
										WHEN [Not] = 0 THEN cast(I as int)
										WHEN ([Not] = 1 AND I = 1) THEN -1000
										WHEN ([Not] = 1 AND I = 0) THEN 0
									END), @Default) <= 0 THEN 0 ELSE 1
				 END as bit) I,
			CAST(CASE
					WHEN ISNULL(SUM(CASE
										WHEN [Not] = 0 THEN cast(S as int)
										WHEN ([Not] = 1 AND S = 1) THEN -1000
										WHEN ([Not] = 1 AND S = 0) THEN 0
									END), @Default) <= 0 THEN 0 ELSE 1
				 END as bit) S
		FROM EnnupleAccessi
		WHERE
			-- Per tutti o per un gruppo specifico
			( IDGruppoUtenti IS NULL
				OR IDGruppoUtenti IN (SELECT ID FROM [dbo].[GetGruppiOePerUtente](@Utente))
			)
	
			-- Per tutti o per sistema erogante
			AND (IDSistemaErogante IS NULL
					OR (IDSistemaErogante = @idSistemaErogante) 
					OR @idSistemaErogante IS NULL)

			-- stato
			AND (IDStato = @idStato)
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreEnnupleAccessiCheck] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreEnnupleAccessiCheck] TO [DataAccessWs]
    AS [dbo];

