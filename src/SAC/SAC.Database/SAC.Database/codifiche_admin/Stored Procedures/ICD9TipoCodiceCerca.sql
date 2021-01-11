CREATE PROC codifiche_admin.ICD9TipoCodiceCerca

AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
	Id,
	Descrizione
  FROM  
	codifiche.ICD9TipoCodice
  ORDER BY 
	ID
	

END
