CREATE ROLE [DataAccessUI]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessUI', @membername = N'PROGEL.IT\DAGOBAH2$';

