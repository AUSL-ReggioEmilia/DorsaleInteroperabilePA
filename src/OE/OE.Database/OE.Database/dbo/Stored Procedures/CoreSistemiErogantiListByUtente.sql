

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-08
-- Modify date: 2017-09-26 Almeno diritti di Strittura/Inoltro
-- Description:	Ritorna un elenco di sistemi eroganti dell'utente
-- =============================================
CREATE PROCEDURE [dbo].[CoreSistemiErogantiListByUtente]
	@Utente AS VARCHAR(64)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
  
	-- Tabella temporanea contenente le ennuple
	DECLARE @T TABLE (IDSistemaErogante uniqueidentifier, [S] bit NOT NULL, [I] bit NOT NULL, [Not] bit NOT NULL) 
	INSERT INTO @T 
		 SELECT [IDSistemaErogante], [S], [I], [Not]
		 FROM dbo.[GetEnnupleAccessi](@Utente, 1)

	SELECT DISTINCT S1.ID
				, A.Codice AS AziendaCodice
				, A.Descrizione AS AziendaDescrizione	
				, S1.Codice AS SistemaCodice
				, S1.Descrizione AS SistemaDescrizione
		FROM
			(
			SELECT S.ID
					, S.CodiceAzienda
					, S.Codice
					, S.Descrizione
			FROM Sistemi S INNER JOIN @T T ON S.ID = T.IDSistemaErogante
			WHERE T.[Not] = 0 AND (T.[S] = 1 OR T.[I] = 1)
				AND S.Erogante = 1 AND S.Attivo=1
				
			UNION
			
			SELECT S.ID
					, S.CodiceAzienda
					, S.Codice AS SistemaCodice
					, S.Descrizione AS SistemaDescrizione
			FROM Sistemi S
			WHERE (SELECT COUNT(*) FROM @T T WHERE T.[Not] = 0 AND (T.[S] = 1 OR T.[I] = 1)	AND IDSistemaErogante IS NULL)>= 1
					AND S.Erogante = 1 AND S.Attivo=1
			) S1
			INNER JOIN Aziende A ON S1.CodiceAzienda = A.Codice

	EXCEPT
			
	-- Tutte i sistemi in [Not]
	SELECT DISTINCT S2.ID
				, A.Codice AS AziendaCodice
				, A.Descrizione AS AziendaDescrizione	
				, S2.Codice AS SistemaCodice
				, S2.Descrizione AS SistemaDescrizione
		FROM
			(
			SELECT S.ID
					, S.CodiceAzienda
					, S.Codice
					, S.Descrizione
			FROM Sistemi S INNER JOIN @T T ON S.ID = T.IDSistemaErogante
			WHERE T.[Not] = 1 AND (T.[S] = 1 OR T.[I] = 1)
				AND S.Erogante = 1 AND S.Attivo=1
				
			UNION
			
			SELECT S.ID
					, S.CodiceAzienda
					, S.Codice AS SistemaCodice
					, S.Descrizione AS SistemaDescrizione
			FROM Sistemi S
			WHERE (SELECT COUNT(*) FROM @T T WHERE T.[Not] = 1 AND (T.[S] = 1 OR T.[I] = 1) AND IDSistemaErogante IS NULL)>= 1
					AND S.Erogante = 1 AND S.Attivo=1
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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreSistemiErogantiListByUtente] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreSistemiErogantiListByUtente] TO [DataAccessWs]
    AS [dbo];

