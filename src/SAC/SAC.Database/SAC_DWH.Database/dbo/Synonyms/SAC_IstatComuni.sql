CREATE SYNONYM [dbo].[SAC_IstatComuni] FOR [AuslAsmnRe_SAC].[dbo].[IstatComuni];




GO
GRANT SELECT
    ON OBJECT::[dbo].[SAC_IstatComuni] TO [ExecuteDwh]
    AS [dbo];

