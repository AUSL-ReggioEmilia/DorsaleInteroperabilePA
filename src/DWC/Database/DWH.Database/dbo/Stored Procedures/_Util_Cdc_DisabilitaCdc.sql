	
CREATE PROCEDURE [dbo].[_Util_Cdc_DisabilitaCdc]	
AS 	
BEGIN
	EXEC sys.sp_cdc_disable_table 'dbo', 'RefertiStili', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'TipiReferto', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'SistemiEroganti', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'RefertiNote', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'StampeConfigurazioniStampa', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'MotiviAccesso', 'all'

	EXEC sys.sp_cdc_disable_table 'sole', 'AbilitazioniSistemi', 'all'
	EXEC sys.sp_cdc_disable_table 'sole', 'AbilitazioniPrestazioni', 'all'

	EXEC sys.sp_cdc_disable_db;
END