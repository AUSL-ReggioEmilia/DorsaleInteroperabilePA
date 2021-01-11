CREATE ROLE [DataAccessSql]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessSql', @membername = N'progel.it\AsmnSac_Anagrafica';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessSql', @membername = N'OE_BT_DA';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessSql', @membername = N'PROGEL.IT\DevBizTalkService';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessSql', @membername = N'SAC_CUP_IMPORT';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessSql', @membername = N'DEV_VS';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessSql', @membername = N'PROGEL.IT\MARCOD-BT09$';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessSql', @membername = N'SAC_GST_ASMN';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessSql', @membername = N'PROGEL.IT\DAGOBAH2$';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessSql', @membername = N'NT AUTHORITY\NETWORK SERVICE';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessSql', @membername = N'SAC_DWC';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessSql', @membername = N'DWH_DAE';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessSql', @membername = N'PROGEL.IT\DevDwhClinicoSite';

