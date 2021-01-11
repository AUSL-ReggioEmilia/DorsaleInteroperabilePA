CREATE ROLE [DataAccessUi]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessUi', @membername = N'PROGEL.IT\DAGOBAH2$';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessUi', @membername = N'NT AUTHORITY\NETWORK SERVICE';

