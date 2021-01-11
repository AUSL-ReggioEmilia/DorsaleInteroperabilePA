

-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2016-05-20
-- Description:	Restituisce la lista dei consensi del paziente
-- =============================================
CREATE FUNCTION [sac].[OttieneConsensiPerIdSac]
(
	@IdSac UNIQUEIDENTIFIER
)
RETURNS 
@Consensi TABLE 
(
	Id uniqueidentifier
	--,Provenienza varchar(16)
	--,IdProvenienza varchar(64)
	,IdPaziente uniqueidentifier
	,Descrizione varchar(64)
	,DataStato datetime
	,Stato bit
	,OperatoreId varchar(64)
	,OperatoreCognome varchar(64)
	,OperatoreNome varchar(64)
	,OperatoreComputer varchar(64)
	--,PazienteProvenienza varchar(16)
	--,PazienteIdProvenienza varchar(64)
	--,PazienteCognome varchar(64)
	--,PazienteNome varchar(64)
	--,PazienteTessera varchar(16)
	--,PazienteCodiceFiscale varchar(16)
	--,PazienteDataNascita datetime
	--,PazienteComuneNascitaCodice varchar(6)
	--,PazienteComuneNascitaNome varchar(128)
	--,PazienteNazionalitaCodice varchar(3)
	--,PazienteNazionalitaNome varchar(64)
)
AS
BEGIN

	INSERT @Consensi 
	SELECT 
		Id
		--, Provenienza, IdProvenienza
		, IdPaziente, Descrizione, DataStato, Stato 
		, OperatoreId, OperatoreCognome, OperatoreNome, OperatoreComputer 
		--, PazienteProvenienza, PazienteIdProvenienza, PazienteCognome, PazienteNome, PazienteTessera, PazienteCodiceFiscale, PazienteDataNascita 
		--, PazienteComuneNascitaCodice, PazienteComuneNascitaNome, PazienteNazionalitaCodice, PazienteNazionalitaNome 
	FROM sac.PazientiConsensi
	WHERE IdPaziente = @IdSac
	
	RETURN 
END