

CREATE PROCEDURE [dbo].[IstatComuniUiSelect]
(
	@Codice varchar(6)
)
AS
BEGIN
/*
	Modifica Ettore 2014-05-20: tolto i campi Obsoleto e ObsoletoData (li restituisco usando i nuovi campi)
*/
	SET NOCOUNT OFF
	SELECT 
		Codice
		,Nome
		,CASE nazione
			WHEN 1 THEN '-10'
			ELSE CodiceProvincia
		END AS CodiceProvincia
		,Nazione
		,CASE 
			WHEN GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE()) THEN
				CAST(0 AS BIT) 
			ELSE CAST(1 AS BIT) 
		END AS Obsoleto
		,DataFineValidita AS ObsoletoData
		,Provenienza
		,IdProvenienza
		,DataInserimento
		,DataInizioValidita
		,DataFineValidita
		,CodiceDistretto
		,Cap
		,CodiceCatastale
		,CodiceRegione
		,Sigla
		,CodiceAsl
		,FlagComuneStatoEstero
		,FlagStatoEsteroUE
		,DataUltimaModifica
		,Disattivato
		,CodiceInternoLha
	FROM  
		IstatComuni
	WHERE 
		Codice = @Codice
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatComuniUiSelect] TO [DataAccessUi]
    AS [dbo];

