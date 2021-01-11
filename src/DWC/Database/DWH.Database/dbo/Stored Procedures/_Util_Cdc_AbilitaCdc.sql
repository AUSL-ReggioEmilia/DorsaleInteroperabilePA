	
CREATE PROCEDURE [dbo].[_Util_Cdc_AbilitaCdc]	
AS	
BEGIN	
	EXEC sys.sp_cdc_enable_db;
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='RefertiStili', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='TipiReferto', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='SistemiEroganti', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='RefertiNote', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='StampeConfigurazioniStampa', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='MotiviAccesso', @role_name='NULL', @supports_net_changes=1

	EXEC sys.sp_cdc_enable_table @source_schema='sole', @source_name='AbilitazioniSistemi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='sole', @source_name='AbilitazioniPrestazioni', @role_name='NULL', @supports_net_changes=1
END