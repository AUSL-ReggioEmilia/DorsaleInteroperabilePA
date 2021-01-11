CREATE ROLE [DataAccessMsg]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessMsg', @membername = N'OE_BT_DA';


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessMsg', @membername = N'PROGEL.IT\ENDOR2$';

