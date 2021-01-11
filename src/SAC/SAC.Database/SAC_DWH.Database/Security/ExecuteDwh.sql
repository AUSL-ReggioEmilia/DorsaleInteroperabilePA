CREATE ROLE [ExecuteDwh]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteDwh', @membername = N'SAC_GST_ASMN';


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteDwh', @membername = N'SAC_DWC';


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteDwh', @membername = N'DWH_DAE';


GO
EXECUTE sp_addrolemember @rolename = N'ExecuteDwh', @membername = N'PROGEL.IT\DevBizTalkService';

