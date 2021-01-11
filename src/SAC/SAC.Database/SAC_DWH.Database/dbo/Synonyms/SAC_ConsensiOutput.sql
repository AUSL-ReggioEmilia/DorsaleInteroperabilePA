CREATE SYNONYM [dbo].[SAC_ConsensiOutput] FOR [AuslAsmnRe_SAC].[dbo].[ConsensiOutput];




GO
GRANT SELECT
    ON OBJECT::[dbo].[SAC_ConsensiOutput] TO [ExecuteDwh]
    AS [dbo];

