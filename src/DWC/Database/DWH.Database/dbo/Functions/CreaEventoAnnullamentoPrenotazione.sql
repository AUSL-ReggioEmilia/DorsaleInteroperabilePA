

-- =============================================
-- Author:		Ettore
-- Create date: 2018-01-09
-- Description:	Costruisce l'XML per la notifica di un evento di annullamento di una PRENOTAZIONE
--				Per Annullare un RICOVERO esiste apposita funzione
-- =============================================
CREATE FUNCTION [dbo].[CreaEventoAnnullamentoPrenotazione]
(
	@XmlEventoIniziale XML			--L'xml dell'evento di IL (calcolato con dbo.GetEventoXml2())
	, @IdEventoAnnullamento UNIQUEIDENTIFIER	--Bisogna passare NEWID()
)
RETURNS XML
AS
BEGIN
	DECLARE @AziendaErogante VARCHAR(16)
	DECLARE @SistemaErogante VARCHAR(16)
	DECLARE @NumeroNosologico VARCHAR(64)
	--
	-- Inizializzo le variabili da usare per il messaggio XML di annullamento
	--
	DECLARE @IdEsternoEventoDiAnnullamento VARCHAR(64) 
	DECLARE @DataInserimentoEventoDiAnnullamento DATETIME = GETDATE()
	DECLARE @DataModificaEventoDiAnnullamento DATETIME = @DataInserimentoEventoDiAnnullamento 
	DECLARE @DataEventoEventoDiAnnullamento DATETIME = @DataInserimentoEventoDiAnnullamento
	DECLARE @TipoEventoAnnullamentoCodice VARCHAR(16) = 'X'
	DECLARE @TipoEventoAnnullamentoDescrizione VARCHAR(64) = 'Annullamento'

	--
	-- Costruisco l'IdEsterno dell'evento di erase: leggo i campi dal messaggio xml
	-- IdEsterno = <AziendaErogante>_<SistemaErogante>_<NumeroNosologico><DataEvento><TipoEventoCodice>
	--
	;WITH XMLNAMESPACES('http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0' as ns)
	SELECT @AziendaErogante = @XmlEventoIniziale.value('(/ns:Evento/AziendaErogante)[1]', 'VARCHAR(16)')

	;WITH XMLNAMESPACES('http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0' as ns)
	SELECT @SistemaErogante = @XmlEventoIniziale.value('(/ns:Evento/SistemaErogante)[1]', 'VARCHAR(16)')

	;WITH XMLNAMESPACES('http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0' as ns)
	SELECT @NumeroNosologico = @XmlEventoIniziale.value('(/ns:Evento/NumeroNosologico)[1]', 'VARCHAR(64)')
		
	SET @IdEsternoEventoDiAnnullamento = @AziendaErogante + '_' + @SistemaErogante + '_' + @NumeroNosologico 
								+ REPLACE(
									REPLACE(
										REPLACE(
											CONVERT(VARCHAR(40), @DataEventoEventoDiAnnullamento, 120), '-', ''
											) , ' ' , ''
										), ':', ''
									)
								+ @TipoEventoAnnullamentoCodice 


		SET @TipoEventoAnnullamentoCodice = 'ML'
		SET @TipoEventoAnnullamentoDescrizione = 'Modifica'

		DECLARE @StatoRicoveroCodice AS VARCHAR(2) = '24' --Ricovero annullato
		DECLARE @StatoRicoveroDescrizione VARCHAR(64) = [dbo].[GetRicoveriStatiDescrizione](@StatoRicoveroCodice)

		DECLARE @CodStatoPrenotazione VARCHAR(1) = '4'
		DECLARE @DescStatoPrenotazione VARCHAR(16) = 'ANNULLATO'
		--
		-- Creo un evento ML con stato = ANNULLAMENTO
		--
		-- Costruisco l'IdEsterno dell'evento di erase:
		-- IdEsterno = <AziendaErogante>_<SistemaErogante>_<NumeroNosologico><DataEvento><TipoEventoCodice>
		--
		SET @IdEsternoEventoDiAnnullamento = @AziendaErogante + '_' + @SistemaErogante + '_' + @NumeroNosologico 
									+ REPLACE(
										REPLACE(
											REPLACE(
												CONVERT(VARCHAR(40), @DataEventoEventoDiAnnullamento, 120), '-', ''
												) , ' ' , ''
											), ':', ''
										)
									+ @TipoEventoAnnullamentoCodice
	SET @XmlEventoIniziale.modify ('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/Id/text())[1]  with sql:variable("@IdEventoAnnullamento")
			');
		--Modifico l'IdEsterno dell'evento
		SET @XmlEventoIniziale.modify ('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/IdEsterno/text())[1]  with sql:variable("@IdEsternoEventoDiAnnullamento")
			');
		--Modifico la DataInserimento
		SET @XmlEventoIniziale.modify ('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/DataInserimento/text())[1]  with sql:variable("@DataInserimentoEventoDiAnnullamento")
			');
		--Modifico la DataModifica
		SET @XmlEventoIniziale.modify ('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/DataModifica/text())[1]  with sql:variable("@DataModificaEventoDiAnnullamento")
			');
		--Modifico la DataEvento: ma non dovrebbe servire a nulla per chi riceve
		SET @XmlEventoIniziale.modify ('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/DataEvento/text())[1]  with sql:variable("@DataEventoEventoDiAnnullamento")
			');
		--Modifico TipoEventoCodice=ML
		SET @XmlEventoIniziale.modify ('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/TipoEventoCodice/text())[1]  with sql:variable("@TipoEventoAnnullamentoCodice") 
			'); 
		--Modifico TipoEventoCodiceDescrizione=Modifica
		SET @XmlEventoIniziale.modify ('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/TipoEventoDescrizione/text())[1]  with sql:variable("@TipoEventoAnnullamentoDescrizione") 
			'); 
		--Sistemo gli attributi CodStatoPrenotazione e DescStatoPrenotazione degli eventi (sono obbligatori, posso fare replace)
		SET @XmlEventoIniziale.modify('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/Attributi/Attributo[@Nome=''CodStatoPrenotazione'']/@Valore)[1] with sql:variable("@CodStatoPrenotazione") 
			');  
		SET @XmlEventoIniziale.modify('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/Attributi/Attributo[@Nome=''DescStatoPrenotazione'']/@Valore)[1] with sql:variable("@DescStatoPrenotazione") 
			');  
		--
		-- Sistemazione dati del ricovero
		--
		--Sistemo i nodi StatoCodice e StatoDescrizione
		SET @XmlEventoIniziale.modify('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/Ricovero/Ricovero/StatoCodice/text())[1] with sql:variable("@StatoRicoveroCodice") 
			');  
		SET @XmlEventoIniziale.modify('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/Ricovero/Ricovero/StatoDescrizione/text())[1] with sql:variable("@StatoRicoveroDescrizione") 
			');  

		--Sistemo gli attributi CodStatoPrenotazione e DescStatoPrenotazione del ricovero
		SET @XmlEventoIniziale.modify('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/Ricovero/Ricovero/Attributi/Attributo[@Nome=''CodStatoPrenotazione'']/@Valore)[1] with sql:variable("@CodStatoPrenotazione") 
			');  
		SET @XmlEventoIniziale.modify('
			declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
			replace value of (ns:Evento/Ricovero/Ricovero/Attributi/Attributo[@Nome=''DescStatoPrenotazione'']/@Valore)[1] with sql:variable("@DescStatoPrenotazione") 
			');  

	--
	--
	--
	RETURN @XmlEventoIniziale

END