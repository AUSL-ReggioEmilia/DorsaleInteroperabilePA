
CREATE VIEW [dbo].[ConsensiDropTable]
AS
SELECT     
	Operazione, 
	Id, 
	Tipo, 
	DataStato, 
	Stato, 
	OperatoreId, 
	OperatoreCognome, 
	OperatoreNome, 
	OperatoreComputer, 
	PazienteProvenienza, 
	PazienteProvenienzaId, 
    PazienteCognome, 
	PazienteNome, 
	PazienteCodiceFiscale, 
	PazienteDataNascita, 
	PazienteComuneNascitaCodice, 
	PazienteNazionalitaCodice,
	PazienteTessera

FROM         
	dbo.ConsensiQueue





GO
GRANT INSERT
    ON OBJECT::[dbo].[ConsensiDropTable] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ConsensiDropTable] TO [DataAccessSql]
    AS [dbo];

