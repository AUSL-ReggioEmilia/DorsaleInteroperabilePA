CREATE ROLE [ExecuteFrontEnd]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteFrontEnd', @membername = N'PROGEL.IT\DevDwhClinicoSite';


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteFrontEnd', @membername = N'PROGEL.IT\DevSharePointSearch';


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteFrontEnd', @membername = N'PROGEL.IT\DAGOBAH2$';

