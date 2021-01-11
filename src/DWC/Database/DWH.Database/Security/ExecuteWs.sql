CREATE ROLE [ExecuteWs]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteWs', @membername = N'PROGEL.IT\DevDwhClinicoSite';


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteWs', @membername = N'PROGEL.IT\DevBizTalkService';

