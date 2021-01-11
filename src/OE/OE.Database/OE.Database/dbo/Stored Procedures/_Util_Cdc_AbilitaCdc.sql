

CREATE PROCEDURE [dbo].[_Util_Cdc_AbilitaCdc]	
AS	
BEGIN	
	EXEC sys.sp_cdc_enable_db

	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='DatiAccessori', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='DatiAccessoriDefault', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='DatiAccessoriPrestazioni', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='DatiAccessoriSistemi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='DatiAggiuntivi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='DatiAccessoriTipi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='Ennuple', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='EnnupleAccessi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='EnnupleDatiAccessori', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='GruppiPrestazioni', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='GruppiUtenti', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='Prestazioni', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='PrestazioniGruppiPrestazioni', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='PrestazioniProfili', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='Sistemi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='UnitaOperative', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='Utenti', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='UtentiGruppiUtenti', @role_name='NULL', @supports_net_changes=1
END