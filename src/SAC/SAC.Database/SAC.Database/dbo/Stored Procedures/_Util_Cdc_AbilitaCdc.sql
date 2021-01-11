
CREATE PROCEDURE [dbo].[_Util_Cdc_AbilitaCdc]	
AS	
BEGIN	
	EXEC sys.sp_cdc_enable_db;
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='Provenienze', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='PazientiUtenti', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='ConsensiUtenti', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='Utenti', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='UnitaOperativeSistemi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='UnitaOperativeRegimi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='UnitaOperative', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='Sistemi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='RuoliUnitaOperativeAttributi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='RuoliUnitaOperative', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='RuoliSistemiAttributi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='RuoliSistemi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='RuoliOggettiActiveDirectory', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='RuoliAttributi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='Ruoli', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='Regimi', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='PermessiUtenti', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='Aziende', @role_name='NULL', @supports_net_changes=1
	EXEC sys.sp_cdc_enable_table @source_schema='organigramma', @source_name='Attributi', @role_name='NULL', @supports_net_changes=1
END

