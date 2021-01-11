
CREATE FUNCTION [dbo].[GetPazientiIdByDipartimento] (@IdPazientiDipartimenti AS VARCHAR(64))  
RETURNS uniqueidentifier AS  
/*
	Funzione che ritorna l'Id del paziente associato a PazientiDipartimenti
	
	MODIFICA ETTORE 2015-07-16: 
		Se viene passato un IdEsternoPaziente (=@IdPazientiDipartimenti) composto da SAC_<guid> dove <guid>
		è l'id di una anagrafica fusa la versione precedente cercava solo nella vista PazientiBase che restituisce
		solo gli attivi. Ora ho aggiunto la ricerca anche nella vista dei fusi.
		In questo modo la funzione restituisce sempre l'IdPaziente attivo.

	MODIFICA SANDRO 2016-05-11: Usa la vista dbo.Pazienti
	MODIFICATA SANDRO 2016-05-012: Usa nuova vista [sac].[PazientiFusioni]
*/
BEGIN 
DECLARE @Ret as uniqueidentifier = NULL
DECLARE @Id as varchar(40)
	
	IF @IdPazientiDipartimenti LIKE 'SAC%'
	BEGIN
		SET @Id = REPLACE(@IdPazientiDipartimenti, 'SAC_', '')
		--
		-- Cerco fra gli attivi
		--
		SELECT @Ret = Id
		FROM [dbo].[Pazienti]
		WHERE Id = CAST(@Id AS uniqueidentifier)
		--
		-- MODIFICA ETTORE 2015-07-16: se non trovato lo cerco fra le fusioni
		--
		IF @Ret IS NULL 
		BEGIN
			SELECT @Ret = IdPazienti --questo è il padre
			FROM [sac].[PazientiFusioni]
			WHERE IdPazienteFuso = CAST(@Id AS uniqueidentifier)
		END 
	END

	RETURN @Ret
END

