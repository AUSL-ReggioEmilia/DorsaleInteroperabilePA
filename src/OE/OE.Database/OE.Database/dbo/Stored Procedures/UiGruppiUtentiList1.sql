

CREATE PROCEDURE [dbo].[UiGruppiUtentiList1]

@Descrizione AS VARCHAR(128) = NULL,
@Utente AS VARCHAR(64) = NULL,
@Note AS VARCHAR(1024) = NULL

AS
BEGIN
SET NOCOUNT ON

  SELECT DISTINCT 
	GU.[ID]
   ,GU.[Descrizione]
   ,dbo.GetUiUtentiGruppiUtentiCount(GU.[ID]) as CountUtenti
   ,GU.[Note]
  FROM
	[dbo].[GruppiUtenti] AS GU
	LEFT JOIN [dbo].UtentiGruppiUtenti AS UGU ON GU.ID = UGU.IDGruppoUtenti
	LEFT JOIN [dbo].Utenti AS U ON UGU.IDUtente = U.ID
  
  WHERE 
	(@Descrizione IS NULL OR GU.[Descrizione] LIKE '%' + @Descrizione + '%')  
	AND
	(@Utente IS NULL OR U.Utente LIKE '%' + @UTENTE + '%')
	AND
	(@Note IS NULL OR GU.Note LIKE '%' + @Note + '%')
		
  ORDER BY GU.Descrizione


END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiGruppiUtentiList1] TO [DataAccessUi]
    AS [dbo];

