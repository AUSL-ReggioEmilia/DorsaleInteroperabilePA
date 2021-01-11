


-- =============================================
-- Author:		Ettore
-- Create date: 2018-01-09
-- Description:	Costruisce l'XML per la notifica di un evento di annullamento di un RICOVERO
--				Per Annullare una PRENOTAZIONE esiste apposita funzione
-- =============================================
CREATE FUNCTION [dbo].[CreaEventoAnnullamentoRicovero]
(
	@XmlEventoIniziale XML						--L'xml dell'evento di Accettazione (calcolato con dbo.GetEventoXml2())
	, @IdEventoAnnullamento UNIQUEIDENTIFIER	--Bisogna passare NEWID()
	, @TipoEventoAnnullamentoCodice VARCHAR(16) --Valori: X, E
	, @TipoEventoAnnullamentoDescrizione VARCHAR(64) --Valori: Annullamento, Cancellazione
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
	--Modifico TipoEventoCodice=E
	SET @XmlEventoIniziale.modify ('
		declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
		replace value of (ns:Evento/TipoEventoCodice/text())[1]  with sql:variable("@TipoEventoAnnullamentoCodice") 
		');
	--Modifico TipoEventoCodiceDescrizione=Cancellazione
	SET @XmlEventoIniziale.modify ('
		declare namespace ns="http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0";
		replace value of (ns:Evento/TipoEventoDescrizione/text())[1]  with sql:variable("@TipoEventoAnnullamentoDescrizione") 
		'); 

	--
	--
	--
	RETURN @XmlEventoIniziale

END