
CREATE PROCEDURE [dbo].[ConsensiQueueAdd]
	  @Operazione AS tinyint
	, @Id AS varchar(64)
	, @Tipo AS varchar(64)
	, @DataStato AS datetime
	, @Stato AS bit
	, @OperatoreId AS varchar(64)
	, @OperatoreCognome AS varchar(64)
	, @OperatoreNome AS varchar(64)
	, @OperatoreComputer AS varchar(64)
	, @PazienteProvenienza AS varchar(16)
	, @PazienteProvenienzaId AS varchar(64)
	, @PazienteCognome AS varchar(64)
	, @PazienteNome AS varchar(64)
	, @PazienteCodiceFiscale AS varchar(16)
	, @PazienteDataNascita AS datetime
	, @PazienteComuneNascitaCodice AS varchar(6)
	, @PazienteNazionalitaCodice AS varchar(3)
	, @PazienteTessera AS varchar(16)

AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [dbo].[ConsensiQueue]
           ([Operazione]
		   ,[Id]
           ,[Tipo]
           ,[DataStato]
           ,[Stato]
           ,[OperatoreId]
           ,[OperatoreCognome]
           ,[OperatoreNome]
           ,[OperatoreComputer]
		   ,[PazienteProvenienza]
		   ,[PazienteProvenienzaId]
           ,[PazienteCognome]
           ,[PazienteNome]
           ,[PazienteCodiceFiscale]
           ,[PazienteDataNascita]
           ,[PazienteComuneNascitaCodice]
           ,[PazienteNazionalitaCodice]
		   ,[PazienteTessera])
     VALUES
           (  @Operazione
			, @Id
			, @Tipo
			, @DataStato
			, @Stato
			, @OperatoreId
			, @OperatoreCognome
			, @OperatoreNome
			, @OperatoreComputer
			, @PazienteProvenienza
			, @PazienteProvenienzaId
			, @PazienteCognome
			, @PazienteNome
			, @PazienteCodiceFiscale
			, @PazienteDataNascita
			, @PazienteComuneNascitaCodice
			, @PazienteNazionalitaCodice
			, @PazienteTessera)

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiQueueAdd] TO [DataAccessSql]
    AS [dbo];

