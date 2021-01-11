CREATE TABLE [sole].[AbilitazioniSistemi] (
    [Id]                           UNIQUEIDENTIFIER CONSTRAINT [DF_Sole_AbilitazioniSistemi_Id] DEFAULT (newsequentialid()) NOT NULL,
    [SistemaErogante]              VARCHAR (16)     NOT NULL,
    [AziendaErogante]              VARCHAR (16)     NOT NULL,
    [TipoErogante]                 VARCHAR (16)     CONSTRAINT [DF_Sole_AbilitazioniSistemi_TipoErogante] DEFAULT ('Referto') NOT NULL,
    [Abilitato]                    BIT              CONSTRAINT [DF_Sole_AbilitazioniSistemi_Abilitato] DEFAULT ((0)) NOT NULL,
    [DataInizio]                   DATETIME         NULL,
    [DataFine]                     DATETIME         NULL,
    [DataModifica]                 DATETIME         CONSTRAINT [DF_Sole_AbilitazioniSistemi_DataModifica] DEFAULT (getdate()) NOT NULL,
    [UtenteModifica]               VARCHAR (64)     CONSTRAINT [DF_Sole_AbilitazioniSistemi_UtenteModifica] DEFAULT (suser_name()) NOT NULL,
    [TipologiaSole]                VARCHAR (16)     CONSTRAINT [DF_Sole_AbilitazioniSistemi_TipologiaSole] DEFAULT ('NonValido') NOT NULL,
    [Mittente]                     VARCHAR (64)     NOT NULL,
    [OreRitardoInvio]              INT              CONSTRAINT [DF_Sole_AbilitazioniSistemi_OreRitardoInvio] DEFAULT ((24)) NOT NULL,
    [DisabilitaControlloRegime]    BIT              CONSTRAINT [DF_Sole_AbilitazioniSistemi_DisabilitaControlloRegime] DEFAULT ((0)) NOT NULL,
    [DisabilitaControlloInviabile] BIT              CONSTRAINT [DF_Sole_AbilitazioniSistemi_DisabilitaControlloInviabile] DEFAULT ((0)) NOT NULL,
    [DisabilitaControlloConsensi]  BIT              CONSTRAINT [DF_Sole_AbilitazioniSistemi_DisabilitaControlloConsensi] DEFAULT ((0)) NOT NULL,
    [Priorita]                     INT              CONSTRAINT [DF_Sole_AbilitazioniSistemi_Priorita] DEFAULT ((5)) NOT NULL,
    [CorrelazioneInvio]            VARCHAR (16)     NULL,
    [InviaOscurati]                BIT              CONSTRAINT [DF_Sole_AbilitazioniSistemi_InviaOscurati] DEFAULT ((0)) NOT NULL,
    [InviaConfidenziali]           BIT              CONSTRAINT [DF_Sole_AbilitazioniSistemi_InviaConfidenziali] DEFAULT ((0)) NOT NULL,
    [InviaLiberaProfessione]       BIT              CONSTRAINT [DF_Sole_AbilitazioniSistemi_InviaLiberaProfessione] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AbilitazioniSistemi] PRIMARY KEY CLUSTERED ([SistemaErogante] ASC, [AziendaErogante] ASC, [TipoErogante] ASC),
    CONSTRAINT [CK_SoleAbilitazioni_Priorita] CHECK ([Priorita]>=(0) AND [Priorita]<=(10)),
    CONSTRAINT [CK_SoleAbilitazioni_TipoErogante] CHECK ([TipoErogante]='Cartella' OR [TipoErogante]='Ricovero' OR [TipoErogante]='Referto' OR [TipoErogante]='Evento')
);




GO
GRANT UPDATE
    ON OBJECT::[sole].[AbilitazioniSistemi] TO [DataAccess_Admin]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[sole].[AbilitazioniSistemi] TO [DataAccess_Admin]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[sole].[AbilitazioniSistemi] TO [DataAccess_Admin]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[sole].[AbilitazioniSistemi] TO [DataAccess_Admin]
    AS [dbo];

