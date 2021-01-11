CREATE ROLE [ExecuteBiztalk]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteBiztalk', @membername = N'PROGEL.IT\DevBizTalkService';

