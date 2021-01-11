CREATE ROLE [DataAccessWs]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessWs', @membername = N'PROGEL.IT\Sviluppo';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessWs', @membername = N'PROGEL.IT\DAGOBAH2$';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessWs', @membername = N'PROGEL.IT\dev_vs';

