CREATE ROLE [ExecuteExt]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteExt', @membername = N'SAC_DWC';


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteExt', @membername = N'DWH_DAE';


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteExt', @membername = N'PROGEL.IT\DevBizTalkService';

