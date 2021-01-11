

CREATE PROCEDURE [dbo].[IstatComuniUiLista]
(
	@Codice varchar(6) = NULL,
	@Nome varchar(128) = NULL,
	@Tipo tinyint = 0,  --  0=NESSUN FILTRO, 1=NAZIONI,  2=COMUNI
	@Provenienza varchar(16) = NULL,
	@IdProvenienza varchar(64) = NULL,
	@Stato tinyint = 0, --  0=NESSUN FILTRO, 1=ATTIVI,  2=OBSOLETI
	@Top int = NULL
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT OFF

	SELECT TOP (ISNULL(@Top,100))
		CASE Nazione
			WHEN 1 THEN 'Nazione'
			WHEN 0 THEN 'Comune'
			ELSE 'Sconosciuto'
		END AS Tipo
		, C.Codice
		, C.Nome
		, CASE C.nazione
			WHEN 1 THEN ''
			ELSE P.nome
		 END AS Provincia
		, CASE
			WHEN GETDATE() BETWEEN COALESCE(C.DataInizioValidita,'1800-01-01') AND COALESCE(C.DataFineValidita,GETDATE()) THEN 'Attivo'
			ELSE 'Obsoleto'
		 END AS Stato           
		, DataInizioValidita
		, DataFineValidita
		, Provenienza
		, IdProvenienza
		, DataInserimento
	FROM  
		IstatComuni AS C
		LEFT JOIN IstatProvince AS P
			ON C.CodiceProvincia = P.Codice
	WHERE 
		(C.Codice = @Codice OR @Codice IS NULL) AND
		(C.Nome LIKE @Nome + '%' OR @Nome IS NULL) AND 
		(
		(@Tipo = 0) OR
		(@Tipo = 1 AND C.Nazione = 1) OR
		(@Tipo = 2 AND C.Nazione = 0) 
		) AND      
		(C.Provenienza = @Provenienza OR @Provenienza IS NULL) AND 
		(C.IdProvenienza = @IdProvenienza OR @IdProvenienza IS NULL) AND
		(
		(@Stato = 0) OR
		(@Stato = 1 AND     GETDATE() BETWEEN COALESCE(C.DataInizioValidita,'1800-01-01') AND COALESCE(C.DataFineValidita,GETDATE()) ) OR
		(@Stato = 2 AND NOT GETDATE() BETWEEN COALESCE(C.DataInizioValidita,'1800-01-01') AND COALESCE(C.DataFineValidita,GETDATE()) ) 
		)            
		AND (C.Codice <> '-1') --elimino il codice usato dall'interfaccia grafica
	ORDER BY 
		C.Codice
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatComuniUiLista] TO [DataAccessUi]
    AS [dbo];

