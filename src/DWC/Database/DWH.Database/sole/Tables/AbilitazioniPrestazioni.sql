CREATE TABLE [sole].[AbilitazioniPrestazioni] (
    [SistemaErogante]                VARCHAR (16) NOT NULL,
    [AziendaErogante]                VARCHAR (16) NOT NULL,
    [PrestazioneCodice]              VARCHAR (12) NOT NULL,
    [DataModifica]                   DATETIME     CONSTRAINT [DF_sole_AbilitazioniPrestazioni_DataModifica] DEFAULT (getdate()) NOT NULL,
    [UtenteModifica]                 VARCHAR (64) CONSTRAINT [DF_sole_AbilitazioniPrestazioni_UtenteModifica] DEFAULT (suser_name()) NOT NULL,
    [Abilitato]                      BIT          CONSTRAINT [DF_sole.AbilitazioniPrestazioni_Abilitato] DEFAULT ((0)) NOT NULL,
    [DisabilitaControlliBloccoInvio] BIT          CONSTRAINT [DF_sole_AbilitazioniPrestazioni_DisabilitaControlloOscuramenti] DEFAULT ((1)) NOT NULL,
    [OreRitardoInvio]                INT          CONSTRAINT [DF_sole_AbilitazioniPrestazioni_OreRitardoInvio] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_sole.AbilitazioniPrestazioni] PRIMARY KEY CLUSTERED ([SistemaErogante] ASC, [AziendaErogante] ASC, [PrestazioneCodice] ASC)
);




GO
GRANT UPDATE
    ON OBJECT::[sole].[AbilitazioniPrestazioni] TO [DataAccess_Admin]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[sole].[AbilitazioniPrestazioni] TO [DataAccess_Admin]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[sole].[AbilitazioniPrestazioni] TO [DataAccess_Admin]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[sole].[AbilitazioniPrestazioni] TO [DataAccess_Admin]
    AS [dbo];

