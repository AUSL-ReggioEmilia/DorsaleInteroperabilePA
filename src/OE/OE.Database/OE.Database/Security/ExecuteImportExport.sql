CREATE ROLE [ExecuteImportExport]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteImportExport', @membername = N'PROGEL.IT\Sviluppo';

