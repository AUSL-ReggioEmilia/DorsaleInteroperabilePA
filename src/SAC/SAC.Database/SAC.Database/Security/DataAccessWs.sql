CREATE ROLE [DataAccessWs]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessWs', @membername = N'DEV_VS';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessWs', @membername = N'PROGEL.IT\MARCOD-BT09$';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessWs', @membername = N'PROGEL.IT\DAGOBAH2$';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessWs', @membername = N'NT AUTHORITY\NETWORK SERVICE';

