

-- =============================================
-- Author:		
-- Modify date: 2018-10-16 - refactoty e lunghezza utente e desc
-- Description:	Controlla se l'utente ha accesso al OE , utente o gruppo
-- =============================================
CREATE PROCEDURE [dbo].[UiUtentiSelect]
(
 @ID AS UNIQUEIDENTIFIER = NULL
,@CodiceDescrizione AS VARCHAR(1024) = NULL
,@Attivo AS BIT = NULL
,@Delega AS INT = NULL
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT Utenti.ID, 
		   Utenti.Utente AS NomeUtente, 
		   ISNULL(Utenti.Descrizione,'') AS Descrizione,
		   Utenti.Attivo,
		   Utenti.Tipo,
		   CASE Utenti.Tipo WHEN 0 THEN 'Utente'
							WHEN 1 THEN 'Gruppo'
							END AS DescrizioneTipo,
		   Utenti.Delega,
		   CASE Utenti.Delega WHEN 0 THEN 'No'
							WHEN 1 THEN 'Può Delegare'
							WHEN 2 THEN 'Deve Delegare'
							ELSE 'Campo Delega non censito: ' + CONVERT(VARCHAR, Utenti.Delega)
							END AS DescrizioneDelega	   
		   
	FROM Utenti 
	
	WHERE (@ID IS NULL OR ID = @ID)
	  AND (@Attivo IS NULL OR Attivo = @Attivo)
	  AND (@Delega IS NULL OR Delega = @Delega)
	  AND (
			@CodiceDescrizione IS NULL 
			OR Utenti.Utente LIKE '%' + @CodiceDescrizione + '%' 
			OR Utenti.Descrizione LIKE '%' + @CodiceDescrizione + '%'
		  )	

	ORDER BY Utenti.Descrizione
END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiUtentiSelect] TO [DataAccessUi]
    AS [dbo];

