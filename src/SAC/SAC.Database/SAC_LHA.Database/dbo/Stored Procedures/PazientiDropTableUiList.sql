

CREATE PROCEDURE [dbo].[PazientiDropTableUiList]
	@IdLha as numeric(10,0)
AS
BEGIN
	SELECT [Id]
		  ,[DataLog]
		  ,[TipoOperazione]
		  ,[IdLha]
		  ,[Inviato]
		  ,[DataInvio]
	  FROM [dbo].[PazientiDropTable]
	  WHERE IdLha = @IdLha
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiDropTableUiList] TO [DataAccessUI]
    AS [dbo];

