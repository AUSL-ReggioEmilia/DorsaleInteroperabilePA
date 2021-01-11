CREATE ROLE [DataAccessDll]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'DataAccessDll', @membername = N'PROGEL.IT\DevBizTalkService';

