CREATE TABLE [dbo].[AppCn_Anagrafe] (
    [IdPersona]                     NUMERIC (10)  NOT NULL,
    [PosizioneAssistenziale]        NVARCHAR (1)  NULL,
    [TesseraSanitaria]              NVARCHAR (16) NULL,
    [CodiceFiscale]                 NVARCHAR (16) NULL,
    [CodiceFiscaleValidato]         NVARCHAR (1)  NULL,
    [Cognome]                       NVARCHAR (40) NULL,
    [Nome]                          NVARCHAR (40) NULL,
    [Sesso]                         NVARCHAR (1)  NULL,
    [DataNascita]                   DATETIME      NULL,
    [DataDecesso]                   DATETIME      NULL,
    [CodiceInternoComuneNascita]    NUMERIC (6)   NULL,
    [CodiceInternoNazionalita]      NVARCHAR (3)  NULL,
    [CodiceInternoComResidenza]     NUMERIC (6)   NULL,
    [IndirizzoResidenza]            NVARCHAR (40) NULL,
    [CAPResidenza]                  NVARCHAR (7)  NULL,
    [CodiceZonaSubcomResidenza]     NVARCHAR (10) NULL,
    [DataDecorrenzaResidenza]       DATETIME      NULL,
    [CodiceRegioneASLResidenza]     NVARCHAR (3)  NULL,
    [CodiceASLResidenza]            NUMERIC (3)   NULL,
    [CodiceInternoComDomicilio]     NUMERIC (6)   NULL,
    [IndirizzoDomicilio]            NVARCHAR (40) NULL,
    [CAPDomicilio]                  NVARCHAR (7)  NULL,
    [CodiceZonaSubcomDomicilio]     NVARCHAR (10) NULL,
    [CodiceRegioneASLAssistenza]    NVARCHAR (3)  NULL,
    [CodiceDistrettoAslAssistenza]  NVARCHAR (5)  NULL,
    [CodiceASLAssistenza]           NUMERIC (3)   NULL,
    [DataInizioAssistenza]          DATETIME      NULL,
    [DataScadenzaAssistenza]        DATETIME      NULL,
    [DataTerminazioneAssistenza]    DATETIME      NULL,
    [CodiceMedicoMMG]               NUMERIC (7)   NULL,
    [CodiceRegionaleMedicoMMG]      NVARCHAR (20) NULL,
    [CognomeNomeMedicoMMG]          NVARCHAR (35) NULL,
    [CodiceDistrettoAslResidenza]   NVARCHAR (5)  NULL,
    [CodiceFiscaleMedicoMMG]        NVARCHAR (16) NULL,
    [DataSceltaMedicoMMG]           DATETIME      NULL,
    [Telefono1]                     NVARCHAR (20) NULL,
    [Telefono2]                     NVARCHAR (20) NULL,
    [Telefono3]                     NVARCHAR (20) NULL,
    [CodiceMotivoTerminazione]      NVARCHAR (5)  NULL,
    [DescrizioneMotivoTerminazione] NVARCHAR (35) NULL,
    [MotivoTerminazioneIndicaMorte] NVARCHAR (1)  NULL,
    [TimestampUltimaModifica]       DATETIME      NULL,
    [IdVariazioneRecordAnagrafico]  NUMERIC (10)  NULL,
    [IdRegionalePersona]            NVARCHAR (35) NULL,
    [Annullato]                     NVARCHAR (1)  NULL,
    [IdVincenteFusione]             NUMERIC (10)  NULL,
    [TimestampFusione]              DATETIME      NULL,
    CONSTRAINT [PK_AppCn_Anagrafe] PRIMARY KEY CLUSTERED ([IdPersona] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [IX_AppCn_Anagrafe_Where]
    ON [dbo].[AppCn_Anagrafe]([CodiceFiscale] ASC)
    INCLUDE([IdPersona], [Cognome], [Nome], [DataNascita], [CodiceInternoComuneNascita], [Annullato]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_AppCn_Anagrafe_Where2]
    ON [dbo].[AppCn_Anagrafe]([Annullato] ASC, [CodiceFiscale] ASC)
    INCLUDE([IdPersona]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_AppCn_Anagrafe_IdVincenteFusione]
    ON [dbo].[AppCn_Anagrafe]([IdVincenteFusione] ASC) WITH (FILLFACTOR = 95);

