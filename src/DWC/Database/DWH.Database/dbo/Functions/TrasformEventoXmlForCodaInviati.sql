
/*
 Ritorna un segmento XML di evento, con una set di dati minimi
 CREATE SANDRO 2015-11-23
 MODIFY SANDRO 2016-06-22 Legge anche TipoEpisodioCodice dagli attributi
*/
CREATE FUNCTION [dbo].[TrasformEventoXmlForCodaInviati](@Evento XML)  
RETURNS XML AS  
BEGIN 
	DECLARE @Dati XML = '<Evento></Evento>'
	DECLARE @Element XML

	SET @Element = '<TipoEventoCodice>'
					+ @Evento.value('(/*/TipoEventoCodice)[1]', 'varchar(16)')
					+ '</TipoEventoCodice>'
	SET @Dati.modify('insert sql:variable("@Element") into (/Evento)[1]')

	SET @Element = '<TipoEpisodioCodice>'
					+ @Evento.value('(/*/Attributi/Attributo[@Nome="TipoEpisodioCodice"]/@Valore)[1]', 'varchar(16)')
					+ '</TipoEpisodioCodice>'
	SET @Dati.modify('insert sql:variable("@Element") into (/Evento)[1]')

	SET @Element = '<TipoRicoveroCodice>'
					+ @Evento.value('(/*/Ricovero/Ricovero/TipoRicoveroCodice)[1]', 'varchar(16)')
					+ '</TipoRicoveroCodice>'
	SET @Dati.modify('insert sql:variable("@Element") into (/Evento)[1]')

	SET @Element = '<StatoRicoveroCodice>'
					+ @Evento.value('(/*/Ricovero/Ricovero/StatoCodice)[1]', 'varchar(16)')
					+ '</StatoRicoveroCodice>'
	SET @Dati.modify('insert sql:variable("@Element") into (/Evento)[1]')
	
	SET @Element = '<AziendaErogante>'
					+ @Evento.value('(/*/AziendaErogante)[1]', 'varchar(64)')
					+ '</AziendaErogante>'
	SET @Dati.modify('insert sql:variable("@Element") into (/Evento)[1]')

	SET @Element = '<SistemaErogante>'
					+ @Evento.value('(/*/SistemaErogante)[1]', 'varchar(64)')
					+ '</SistemaErogante>'
	SET @Dati.modify('insert sql:variable("@Element") into (/Evento)[1]')

	RETURN @Dati
END