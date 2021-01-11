
/*
 Ritorna un segmento XML di referto, con una set di dati minimi
 CREATE SANDRO 2015-11-20 
*/
CREATE FUNCTION [dbo].[TrasformRefertoXmlForCodaInviati](@Referto XML)  
RETURNS XML AS  
BEGIN 
	DECLARE @Dati XML = '<Referto></Referto>'
	DECLARE @Element XML

	SET @Element = '<StatoRichiestaCodice>'
					+ @Referto.value('(/*/StatoRichiestaCodice)[1]', 'varchar(1)')
					+ '</StatoRichiestaCodice>'
	SET @Dati.modify('insert sql:variable("@Element") into (/Referto)[1]')

	SET @Element = '<AziendaErogante>'
					+ @Referto.value('(/*/AziendaErogante)[1]', 'varchar(64)')
					+ '</AziendaErogante>'
	SET @Dati.modify('insert sql:variable("@Element") into (/Referto)[1]')

	SET @Element = '<SistemaErogante>'
					+ @Referto.value('(/*/SistemaErogante)[1]', 'varchar(64)')
					+ '</SistemaErogante>'
	SET @Dati.modify('insert sql:variable("@Element") into (/Referto)[1]')

	RETURN @Dati
END