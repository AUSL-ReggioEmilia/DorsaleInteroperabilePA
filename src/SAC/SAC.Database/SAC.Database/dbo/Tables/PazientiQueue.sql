CREATE TABLE [dbo].[PazientiQueue] (
    [IdSeq]                      UNIQUEIDENTIFIER CONSTRAINT [DF_PazientiQueue_IdSeq] DEFAULT (newsequentialid()) NOT NULL,
    [DataOperazione]             DATETIME         CONSTRAINT [DF_PazientiDropTable_DataLog] DEFAULT (getdate()) NOT NULL,
    [Utente]                     VARCHAR (64)     CONSTRAINT [DF_PazientiDropTable_Utente] DEFAULT (user_name()) NOT NULL,
    [Operazione]                 TINYINT          CONSTRAINT [DF_PazientiQueue_Operazione] DEFAULT ((0)) NOT NULL,
    [Id]                         VARCHAR (64)     NOT NULL,
    [Tessera]                    VARCHAR (16)     NULL,
    [Cognome]                    VARCHAR (64)     NULL,
    [Nome]                       VARCHAR (64)     NULL,
    [DataNascita]                DATETIME         NULL,
    [Sesso]                      VARCHAR (1)      NULL,
    [ComuneNascitaCodice]        VARCHAR (6)      NULL,
    [NazionalitaCodice]          VARCHAR (3)      NULL,
    [CodiceFiscale]              VARCHAR (16)     NULL,
    [DatiAnagmestici]            VARCHAR (8000)   NULL,
    [MantenimentoPediatra]       BIT              NULL,
    [CapoFamiglia]               BIT              NULL,
    [Indigenza]                  BIT              NULL,
    [CodiceTerminazione]         VARCHAR (8)      NULL,
    [DescrizioneTerminazione]    VARCHAR (64)     NULL,
    [ComuneResCodice]            VARCHAR (6)      NULL,
    [SubComuneRes]               VARCHAR (64)     NULL,
    [IndirizzoRes]               VARCHAR (256)    NULL,
    [LocalitaRes]                VARCHAR (128)    NULL,
    [CapRes]                     VARCHAR (8)      NULL,
    [DataDecorrenzaRes]          DATETIME         NULL,
    [ComuneAslResCodice]         VARCHAR (6)      NULL,
    [CodiceAslRes]               VARCHAR (3)      NULL,
    [RegioneResCodice]           VARCHAR (3)      NULL,
    [ComuneDomCodice]            VARCHAR (6)      NULL,
    [SubComuneDom]               VARCHAR (64)     NULL,
    [IndirizzoDom]               VARCHAR (256)    NULL,
    [LocalitaDom]                VARCHAR (128)    NULL,
    [CapDom]                     VARCHAR (8)      NULL,
    [PosizioneAss]               TINYINT          NULL,
    [RegioneAssCodice]           VARCHAR (3)      NULL,
    [ComuneAslAssCodice]         VARCHAR (6)      NULL,
    [CodiceAslAss]               VARCHAR (3)      NULL,
    [DataInizioAss]              DATETIME         NULL,
    [DataScadenzaAss]            DATETIME         NULL,
    [DataTerminazioneAss]        DATETIME         NULL,
    [DistrettoAmm]               VARCHAR (8)      NULL,
    [DistrettoTer]               VARCHAR (16)     NULL,
    [Ambito]                     VARCHAR (16)     NULL,
    [CodiceMedicoDiBase]         INT              NULL,
    [CodiceFiscaleMedicoDiBase]  VARCHAR (16)     NULL,
    [CognomeNomeMedicoDiBase]    VARCHAR (128)    NULL,
    [DistrettoMedicoDiBase]      VARCHAR (8)      NULL,
    [DataSceltaMedicoDiBase]     DATETIME         NULL,
    [ComuneRecapitoCodice]       VARCHAR (6)      NULL,
    [IndirizzoRecapito]          VARCHAR (64)     NULL,
    [LocalitaRecapito]           VARCHAR (64)     NULL,
    [Telefono1]                  VARCHAR (20)     NULL,
    [Telefono2]                  VARCHAR (20)     NULL,
    [Telefono3]                  VARCHAR (20)     NULL,
    [CodiceSTP]                  VARCHAR (32)     NULL,
    [DataInizioSTP]              DATETIME         NULL,
    [DataFineSTP]                DATETIME         NULL,
    [MotivoAnnulloSTP]           VARCHAR (8)      NULL,
    [FusioneId]                  VARCHAR (64)     NULL,
    [FusioneCognome]             VARCHAR (64)     NULL,
    [FusioneNome]                VARCHAR (64)     NULL,
    [FusioneTessera]             VARCHAR (16)     NULL,
    [FusioneDataNascita]         DATETIME         NULL,
    [FusioneSesso]               VARCHAR (1)      NULL,
    [FusioneComuneNascitaCodice] VARCHAR (6)      NULL,
    [FusioneNazionalitaCodice]   VARCHAR (3)      NULL,
    [FusioneCodiceFiscale]       VARCHAR (16)     NULL,
    CONSTRAINT [PK_PazientiQueue] PRIMARY KEY CLUSTERED ([IdSeq] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_PazientiQueue_Utenti] FOREIGN KEY ([Utente]) REFERENCES [dbo].[Utenti] ([Utente])
);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiQueue_Data]
    ON [dbo].[PazientiQueue]([DataOperazione] ASC) WITH (FILLFACTOR = 95);


GO
CREATE TRIGGER [dbo].[TrgPazientiQueueIns] 
   ON  [dbo].[PazientiQueue] 
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	IF [dbo].[LeggePazientiPermessiScrittura](NULL) = 0
	BEGIN
		ROLLBACK

		EXEC PazientiAccessiLogAdd 21, USER_NAME, 'DropTable', 'Utente non ha i permessi di scrittura!'

		RAISERROR (N'Utente non ha i permessi di scrittura!', 10, 1)
	END
END
