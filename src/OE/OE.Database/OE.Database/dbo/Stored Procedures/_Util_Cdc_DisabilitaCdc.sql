	
CREATE PROCEDURE [dbo].[_Util_Cdc_DisabilitaCdc]	
AS 	
BEGIN	
	EXEC sys.sp_cdc_disable_table 'dbo', 'DatiAccessori', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'DatiAccessoriDefault', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'DatiAccessoriPrestazioni', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'DatiAccessoriSistemi', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'DatiAggiuntivi', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'DatiAccessoriTipi', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'Ennuple', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'EnnupleAccessi', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'EnnupleDatiAccessori', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'GruppiPrestazioni', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'GruppiUtenti', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'Prestazioni', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'PrestazioniGruppiPrestazioni', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'PrestazioniProfili', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'Sistemi', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'UnitaOperative', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'Utenti', 'all'
	EXEC sys.sp_cdc_disable_table 'dbo', 'UtentiGruppiUtenti', 'all'

	EXEC sys.sp_cdc_disable_db
END