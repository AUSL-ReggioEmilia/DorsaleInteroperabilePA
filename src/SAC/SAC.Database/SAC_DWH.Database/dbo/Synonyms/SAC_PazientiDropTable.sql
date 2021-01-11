CREATE SYNONYM [dbo].[SAC_PazientiDropTable] FOR [AuslAsmnRe_SAC].[dbo].[PazientiDropTable];




GO
GRANT INSERT
    ON OBJECT::[dbo].[SAC_PazientiDropTable] TO [ExecuteDwh]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[SAC_PazientiDropTable] TO [ExecuteDwh]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[SAC_PazientiDropTable] TO [ExecuteDwh]
    AS [dbo];

