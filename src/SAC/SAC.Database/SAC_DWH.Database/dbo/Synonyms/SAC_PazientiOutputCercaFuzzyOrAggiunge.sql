CREATE SYNONYM [dbo].[SAC_PazientiOutputCercaFuzzyOrAggiunge] FOR [AuslAsmnRe_SAC].[dbo].[PazientiOutputCercaFuzzyOrAggiunge];




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SAC_PazientiOutputCercaFuzzyOrAggiunge] TO [ExecuteDwh]
    AS [dbo];

