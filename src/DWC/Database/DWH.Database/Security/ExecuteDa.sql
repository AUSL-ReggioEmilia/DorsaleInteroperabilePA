CREATE ROLE [ExecuteDa]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteDa', @membername = N'PROGEL.IT\DevDwhClinicoSite';


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteDa', @membername = N'PROGEL.IT\DevBizTalkService';

