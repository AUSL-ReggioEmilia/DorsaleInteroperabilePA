CREATE SYNONYM [dbo].[SAC_PazientiOutputCercaAggancioPaziente] FOR [AuslAsmnRe_SAC].[dbo].[PazientiOutputCercaAggancioPaziente];




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SAC_PazientiOutputCercaAggancioPaziente] TO [ExecuteDwh]
    AS [dbo];

