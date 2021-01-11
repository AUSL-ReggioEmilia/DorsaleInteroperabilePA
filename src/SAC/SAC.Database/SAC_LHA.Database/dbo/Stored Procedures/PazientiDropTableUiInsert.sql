

CREATE PROCEDURE [dbo].[PazientiDropTableUiInsert]
	@IdLha as numeric(10,0)
AS
BEGIN
	INSERT INTO [dbo].[PazientiDropTable]
			   ([DataLog]
			   ,[TipoOperazione]
			   ,[IdLha]
			   ,[Inviato]
			   ,[DataInvio])
		 VALUES
			   (GETDATE()
			   ,1
			   ,@IdLha
			   ,0
			   ,null)
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiDropTableUiInsert] TO [DataAccessUI]
    AS [dbo];

