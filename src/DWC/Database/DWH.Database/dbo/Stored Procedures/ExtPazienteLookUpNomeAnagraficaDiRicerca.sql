
CREATE  PROCEDURE [dbo].[ExtPazienteLookUpNomeAnagraficaDiRicerca]
 (
	@NomeAnagrafica AS varchar (16),
	@AziendaErogante AS VARCHAR(16)=NULL	
) AS
--
-- Azienda erogante non puo essere vuota!
-- Viene controllata dalla DataAccess
--
	
	IF @NomeAnagrafica = 'SMS'
		SET @NomeAnagrafica = 'GST_' + UPPER(@AziendaErogante) 
		
	IF @NomeAnagrafica = 'GST_AUSL'
		SET @NomeAnagrafica = 'LHA'
		
	SELECT @NomeAnagrafica AS NomeAnagrafica

	RETURN 0





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtPazienteLookUpNomeAnagraficaDiRicerca] TO [ExecuteExt]
    AS [dbo];

