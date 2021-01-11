CREATE SYNONYM [dbo].[SAC_ConsensiOutputByIdPaziente] FOR [AuslAsmnRe_SAC].[dbo].[ConsensiOutputByIdPaziente];




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SAC_ConsensiOutputByIdPaziente] TO [ExecuteDwh]
    AS [dbo];

