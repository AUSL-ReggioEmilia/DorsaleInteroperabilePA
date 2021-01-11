
CREATE PROCEDURE [dbo].[PazientiUiMergeSelect]
	@IdPaziente AS uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT 
		pf.IdPaziente, 
		pf.IdPazienteFuso, 
		pf.Abilitato,
		p.Provenienza,
		p.IdProvenienza,
		p.Cognome, 
		p.Nome, 
		p.DataNascita
	FROM PazientiFusioni pf INNER JOIN Pazienti p
		ON pf.IdPazienteFuso = p.Id
	WHERE 
		pf.IdPaziente = @IdPaziente
		AND pf.ProgressivoFusione = 1
	ORDER BY p.Cognome




END











GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiMergeSelect] TO [DataAccessUi]
    AS [dbo];

