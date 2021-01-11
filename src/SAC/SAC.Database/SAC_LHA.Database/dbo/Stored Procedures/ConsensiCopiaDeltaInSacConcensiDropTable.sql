

CREATE PROCEDURE [dbo].[ConsensiCopiaDeltaInSacConcensiDropTable]
	 @Batch int = 5000
	,@FinoDataSinc datetime = NULL
AS
BEGIN

	EXECUTE AS LOGIN = 'SAC_LHA_FULLSYNC'
	IF @@ERROR <> 0
		BEGIN
			PRINT 'Errore duranteone EXECUTE AS LOGIN = SAC_LHA_FULLSYNC'
			GOTO ERR_EXIT
		END

	DECLARE @UserName AS VARCHAR(64)
	SET @UserName = SUSER_NAME()

	DECLARE @DataSessione AS DATETIME
	SET @DataSessione = GETDATE()

	IF @FinoDataSinc IS NULL
		SET @FinoDataSinc = GETDATE()

	PRINT 'Data sessione = ' + CONVERT(VARCHAR(20), @DataSessione, 120)
	PRINT 'Utente corrente = ' + @UserName
	
	BEGIN TRAN
	
	UPDATE [SacConnLha].[dbo].[ConsensiDropTable]
		SET [DataElaborazione] = @DataSessione
	  WHERE [IdKey] IN ( SELECT TOP (@Batch) dt.IdKey
						   FROM [SacConnLha].[dbo].[ConsensiDropTable] dt
						  WHERE dt.[DataElaborazione] IS NULL
							AND dt.DataInserimento <= @FinoDataSinc
						  ORDER BY dt.[IdKey] )

	INSERT INTO [SAC].[dbo].[ConsensiDropTable]
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
	SELECT [Operazione]
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
		  ,[PazienteTessera]
	  FROM [SacConnLha].[dbo].[ConsensiDropTable]
	  WHERE [DataElaborazione] = @DataSessione
	  ORDER BY [IdKey]

	IF @@ERROR <> 0
		GOTO ERR_EXIT
		
  	COMMIT
  	RETURN 0
  	
ERR_EXIT:
  	ROLLBACK
  	RETURN 1

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiCopiaDeltaInSacConcensiDropTable] TO [DataAccessSSIS]
    AS [dbo];

