

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2017-09-26 Copiata da [CoreSistemiErogantiListByUtente]
--							in più valuta qualsiasi diritto e ritorna nella lista
-- Description:	Ritorna un elenco di sistemi eroganti dell'utente
-- =============================================
CREATE PROCEDURE [dbo].[CoreSistemiErogantiAccessiListByUtente]
	@Utente AS VARCHAR(64)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
  
	-- Tabella temporanea contenente le ennuple
	DECLARE @T TABLE (IDSistemaErogante uniqueidentifier, [R] bit NOT NULL, [S] bit NOT NULL, [I] bit NOT NULL, [Not] bit NOT NULL) 
	INSERT INTO @T 
		 SELECT [IDSistemaErogante], [R], [S], [I], [Not]
		 FROM dbo.[GetEnnupleAccessi](@Utente, 1)

	SELECT DISTINCT S1.ID
				, A.Codice AS AziendaCodice
				, A.Descrizione AS AziendaDescrizione	
				, S1.Codice AS SistemaCodice
				, S1.Descrizione AS SistemaDescrizione
				, S1.[R] AS AccessoLettura
				, S1.[I] AS AccessoInserimento
				, S1.[S] AS AccessoInoltro
		FROM
			(
			SELECT S.ID
					, S.CodiceAzienda
					, S.Codice
					, S.Descrizione
					, T.[R]
					, T.[S]
					, T.[I]
			FROM Sistemi S INNER JOIN @T T ON S.ID = T.IDSistemaErogante
			WHERE T.[Not] = 0 AND (T.[R] = 1 OR T.[S] = 1 OR T.[I] = 1)
				AND S.Erogante = 1 AND S.Attivo=1
				
			UNION
			
			SELECT S.ID
					, S.CodiceAzienda
					, S.Codice AS SistemaCodice
					, S.Descrizione AS SistemaDescrizione
					, T.[R]
					, T.[S]
					, T.[I]
			FROM Sistemi S
					CROSS APPLY (SELECT TOP 1 T.[R], T.[S], T.[I]
						FROM @T T
						WHERE T.[Not] = 0 AND (T.[R] = 1 OR T.[S] = 1 OR T.[I] = 1)
						AND IDSistemaErogante IS NULL) T
			WHERE S.Erogante = 1 AND S.Attivo=1
			) S1
			INNER JOIN Aziende A ON S1.CodiceAzienda = A.Codice

	EXCEPT
			
	-- Tutte i sistemi in [Not]
	SELECT DISTINCT S2.ID
				, A.Codice AS AziendaCodice
				, A.Descrizione AS AziendaDescrizione	
				, S2.Codice AS SistemaCodice
				, S2.Descrizione AS SistemaDescrizione
				, S2.[R] AS AccessoLettura
				, S2.[S] AS AccessoInserimento
				, S2.[I] AS AccessoInoltro
		FROM
			(
			SELECT S.ID
					, S.CodiceAzienda
					, S.Codice
					, S.Descrizione
					, T.[R]
					, T.[S]
					, T.[I]
			FROM Sistemi S INNER JOIN @T T ON S.ID = T.IDSistemaErogante
			WHERE T.[Not] = 1 AND (T.[R] = 1 OR T.[S] = 1 OR T.[I] = 1)
				AND S.Erogante = 1 AND S.Attivo=1
				
			UNION
			
			SELECT S.ID
					, S.CodiceAzienda
					, S.Codice AS SistemaCodice
					, S.Descrizione AS SistemaDescrizione
					, T.[R]
					, T.[S]
					, T.[I]
			FROM Sistemi S
					CROSS APPLY (SELECT TOP 1 T.[R], T.[S], T.[I]
						FROM @T T
						WHERE T.[Not] = 1 AND (T.[R] = 1 OR T.[S] = 1 OR T.[I] = 1)
						AND IDSistemaErogante IS NULL) T
			WHERE S.Erogante = 1 AND S.Attivo=1
			) S2
			INNER JOIN Aziende A ON S2.CodiceAzienda = A.Codice
		
	ORDER BY A.Codice, S1.Codice
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END