-- =============================================
-- Author:		
-- Modify date: 2018-10-16 - refactoty e lunghezza utente e desc
-- Description:	Controlla se l'utente ha accesso al OE , utente o gruppo
-- =============================================
CREATE PROCEDURE [dbo].[UiUtentiList1]
(
 @IDGruppo as uniqueidentifier
,@Descrizione AS VARCHAR(1024) = NULL
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT Utenti.ID, 
	   ISNULL (Utenti.Utente, '-') as NomeUtente, 
	   ISNULL (Utenti.Descrizione, '-') as Descrizione,
	   Utenti.Attivo,
	   Utenti.Delega,
	   Utenti.Tipo,
	   CASE Utenti.Tipo  WHEN 0 THEN 'Utente'
				WHEN 1 THEN 'Gruppo'
				ELSE 'Tipo sconosciuto' END AS DescrizioneTipo
	   
	FROM UtentiGruppiUtenti
		LEFT JOIN Utenti ON Utenti.ID = UtentiGruppiUtenti.IDUtente
	
	WHERE UtentiGruppiUtenti.IDGruppoUtenti = @IDGruppo
		AND (
				@Descrizione IS NULL
			OR [Descrizione] LIKE '%' + @Descrizione + '%'
			OR [Utente] LIKE '%' + @Descrizione + '%'
			)  

	ORDER BY Utenti.Descrizione
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiUtentiList1] TO [DataAccessUi]
    AS [dbo];

