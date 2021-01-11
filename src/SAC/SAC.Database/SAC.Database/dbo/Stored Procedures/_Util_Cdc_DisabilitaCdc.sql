

CREATE PROCEDURE [dbo].[_Util_Cdc_DisabilitaCdc]	
AS 	
BEGIN	
	EXEC sys.sp_cdc_disable_table 'dbo', 'Provenienze', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'PazientiUtenti', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'ConsensiUtenti', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'Utenti', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'UnitaOperativeSistemi', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'UnitaOperativeRegimi', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'UnitaOperative', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'Sistemi', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'RuoliUnitaOperativeAttributi', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'RuoliUnitaOperative', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'RuoliSistemiAttributi', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'RuoliSistemi', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'RuoliOggettiActiveDirectory', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'RuoliAttributi', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'Ruoli', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'Regimi', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'PermessiUtenti', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'Aziende', 'all'
	EXEC sys.sp_cdc_disable_table 'organigramma', 'Attributi', 'all'
	EXEC sys.sp_cdc_disable_db;
END


