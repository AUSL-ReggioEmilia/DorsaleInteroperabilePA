

-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2016-05-20
-- Description:	Accesso al SAC - I consensi del paziente
-- =============================================
CREATE VIEW [sac].[PazientiConsensi]
AS
	SELECT	
		Id
		, Provenienza
		, IdProvenienza
		, IdPaziente --questo può essere un Id di un paziente attivo o di un fuso
		--Questa è la descrizione del consenso
		, Tipo AS Descrizione
		, DataStato
		, Stato
		, OperatoreId
		, OperatoreCognome
		, OperatoreNome
		, OperatoreComputer
		, PazienteProvenienza
		, PazienteIdProvenienza
		, PazienteCognome
		, PazienteNome
		, PazienteTessera
		, PazienteCodiceFiscale
		, PazienteDataNascita
		, PazienteComuneNascitaCodice
		, PazienteComuneNascitaNome
		, PazienteNazionalitaCodice
		, PazienteNazionalitaNome	
	FROM 
		SAC_Consensi WITH(NOLOCK)