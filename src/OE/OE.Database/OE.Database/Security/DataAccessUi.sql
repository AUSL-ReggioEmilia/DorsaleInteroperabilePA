CREATE ROLE [DataAccessUi]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessUi', @membername = N'PROGEL.IT\Sviluppo';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessUi', @membername = N'PROGEL.IT\dagobah$';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessUi', @membername = N'PROGEL.IT\DAGOBAH2$';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessUi', @membername = N'PROGEL.IT\dev_vs';

