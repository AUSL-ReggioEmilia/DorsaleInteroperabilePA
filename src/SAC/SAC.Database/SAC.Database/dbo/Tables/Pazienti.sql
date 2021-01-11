CREATE TABLE [dbo].[Pazienti] (
    [Id]                        UNIQUEIDENTIFIER CONSTRAINT [DF_Pazienti_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [DataInserimento]           DATETIME         NOT NULL,
    [DataModifica]              DATETIME         NOT NULL,
    [DataDisattivazione]        DATETIME         NULL,
    [DataSequenza]              DATETIME         NOT NULL,
    [LivelloAttendibilita]      TINYINT          NOT NULL,
    [Disattivato]               TINYINT          CONSTRAINT [DF_Pazienti_Cancellato] DEFAULT ((0)) NOT NULL,
    [Ts]                        ROWVERSION       NOT NULL,
    [Provenienza]               VARCHAR (16)     NOT NULL,
    [IdProvenienza]             VARCHAR (64)     NOT NULL,
    [Tessera]                   VARCHAR (16)     NULL,
    [Cognome]                   VARCHAR (64)     NULL,
    [Nome]                      VARCHAR (64)     NULL,
    [DataNascita]               DATETIME         NULL,
    [Sesso]                     VARCHAR (1)      NULL,
    [ComuneNascitaCodice]       VARCHAR (6)      NULL,
    [NazionalitaCodice]         VARCHAR (3)      NULL,
    [CodiceFiscale]             VARCHAR (16)     NULL,
    [DatiAnamnestici]           VARBINARY (MAX)  NULL,
    [MantenimentoPediatra]      BIT              NULL,
    [CapoFamiglia]              BIT              NULL,
    [Indigenza]                 BIT              NULL,
    [CodiceTerminazione]        VARCHAR (8)      NULL,
    [DescrizioneTerminazione]   VARCHAR (64)     NULL,
    [ComuneResCodice]           VARCHAR (6)      NULL,
    [SubComuneRes]              VARCHAR (64)     NULL,
    [IndirizzoRes]              VARCHAR (256)    NULL,
    [LocalitaRes]               VARCHAR (128)    NULL,
    [CapRes]                    VARCHAR (8)      NULL,
    [DataDecorrenzaRes]         DATETIME         NULL,
    [ComuneAslResCodice]        VARCHAR (6)      NULL,
    [CodiceAslRes]              VARCHAR (3)      NULL,
    [ComuneDomCodice]           VARCHAR (6)      NULL,
    [SubComuneDom]              VARCHAR (64)     NULL,
    [IndirizzoDom]              VARCHAR (256)    NULL,
    [LocalitaDom]               VARCHAR (128)    NULL,
    [CapDom]                    VARCHAR (8)      NULL,
    [PosizioneAss]              TINYINT          NULL,
    [ComuneAslAssCodice]        VARCHAR (6)      NULL,
    [CodiceAslAss]              VARCHAR (3)      NULL,
    [DataInizioAss]             DATETIME         NULL,
    [DataScadenzaAss]           DATETIME         NULL,
    [DataTerminazioneAss]       DATETIME         NULL,
    [DistrettoAmm]              VARCHAR (8)      NULL,
    [DistrettoTer]              VARCHAR (16)     NULL,
    [Ambito]                    VARCHAR (16)     NULL,
    [CodiceMedicoDiBase]        INT              NULL,
    [CodiceFiscaleMedicoDiBase] VARCHAR (16)     NULL,
    [CognomeNomeMedicoDiBase]   VARCHAR (128)    NULL,
    [DistrettoMedicoDiBase]     VARCHAR (8)      NULL,
    [DataSceltaMedicoDiBase]    DATETIME         NULL,
    [ComuneRecapitoCodice]      VARCHAR (6)      NULL,
    [IndirizzoRecapito]         VARCHAR (256)    NULL,
    [LocalitaRecapito]          VARCHAR (128)    NULL,
    [Telefono1]                 VARCHAR (20)     NULL,
    [Telefono2]                 VARCHAR (20)     NULL,
    [Telefono3]                 VARCHAR (20)     NULL,
    [CodiceSTP]                 VARCHAR (32)     NULL,
    [DataInizioSTP]             DATETIME         NULL,
    [DataFineSTP]               DATETIME         NULL,
    [MotivoAnnulloSTP]          VARCHAR (8)      NULL,
    [Occultato]                 BIT              CONSTRAINT [DF_Pazienti_Occultato] DEFAULT ((0)) NOT NULL,
    [RegioneResCodice]          VARCHAR (3)      NULL,
    [RegioneAssCodice]          VARCHAR (3)      NULL,
    [Attributi]                 XML              NULL,
    [DataUltimoUtilizzo]        DATETIME         NULL,
    CONSTRAINT [PK_Pazienti] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_Disattivato] CHECK ([Disattivato]=(0) AND [DataDisattivazione] IS NULL OR [Disattivato]>(0) AND NOT [DataDisattivazione] IS NULL),
    CONSTRAINT [FK_Pazienti_IstatAsl_AslAss] FOREIGN KEY ([CodiceAslAss], [ComuneAslAssCodice]) REFERENCES [dbo].[IstatAsl] ([Codice], [CodiceComune]),
    CONSTRAINT [FK_Pazienti_IstatAsl_AslRes] FOREIGN KEY ([CodiceAslRes], [ComuneAslResCodice]) REFERENCES [dbo].[IstatAsl] ([Codice], [CodiceComune]),
    CONSTRAINT [FK_Pazienti_IstatComuni_Dom] FOREIGN KEY ([ComuneDomCodice]) REFERENCES [dbo].[IstatComuni] ([Codice]),
    CONSTRAINT [FK_Pazienti_IstatComuni_Nascita] FOREIGN KEY ([ComuneNascitaCodice]) REFERENCES [dbo].[IstatComuni] ([Codice]),
    CONSTRAINT [FK_Pazienti_IstatComuni_Recapito] FOREIGN KEY ([ComuneRecapitoCodice]) REFERENCES [dbo].[IstatComuni] ([Codice]),
    CONSTRAINT [FK_Pazienti_IstatComuni_Res] FOREIGN KEY ([ComuneResCodice]) REFERENCES [dbo].[IstatComuni] ([Codice]),
    CONSTRAINT [FK_Pazienti_IstatNazioni_Nazionalita] FOREIGN KEY ([NazionalitaCodice]) REFERENCES [dbo].[IstatNazioni] ([Codice]),
    CONSTRAINT [FK_Pazienti_PosizioneAss] FOREIGN KEY ([PosizioneAss]) REFERENCES [dbo].[PazientiPosizioneAss] ([Codice]),
    CONSTRAINT [FK_Pazienti_Provenienze] FOREIGN KEY ([Provenienza]) REFERENCES [dbo].[Provenienze] ([Provenienza])
);










GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Pazienti_Esterno]
    ON [dbo].[Pazienti]([Provenienza] ASC, [IdProvenienza] ASC, [DataDisattivazione] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Pazienti_Generalita]
    ON [dbo].[Pazienti]([Cognome] ASC, [Nome] ASC, [DataNascita] ASC, [ComuneNascitaCodice] ASC, [CodiceFiscale] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Pazienti_CodiceFiscale]
    ON [dbo].[Pazienti]([CodiceFiscale] ASC, [Cognome] ASC, [Nome] ASC)
    INCLUDE([Id], [DataDisattivazione], [Disattivato]) WITH (FILLFACTOR = 70);




GO
CREATE NONCLUSTERED INDEX [IX_Pazienti_DataModifica]
    ON [dbo].[Pazienti]([DataModifica] ASC, [Provenienza] ASC)
    INCLUDE([DataUltimoUtilizzo]) WITH (FILLFACTOR = 70);




GO
CREATE NONCLUSTERED INDEX [IX_MedicoBaseCodiceFiscale]
    ON [dbo].[Pazienti]([CodiceFiscaleMedicoDiBase] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Attivo; 1=Cancellato; 2=Fuso', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Pazienti', @level2type = N'COLUMN', @level2name = N'Disattivato';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0= residente 1= assistito 2= esterno 9= terminato', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Pazienti', @level2type = N'COLUMN', @level2name = N'PosizioneAss';


GO
CREATE NONCLUSTERED INDEX [IX_DataNascita]
    ON [dbo].[Pazienti]([DataNascita] ASC, [ComuneNascitaCodice] ASC)
    INCLUDE([Id]);


GO
CREATE NONCLUSTERED INDEX [IX_Pazienti_Tessera]
    ON [dbo].[Pazienti]([Tessera] ASC, [Cognome] ASC, [Nome] ASC)
    INCLUDE([Id], [DataDisattivazione], [Disattivato]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_DataTerminazione]
    ON [dbo].[Pazienti]([CodiceTerminazione] ASC, [DataTerminazioneAss] ASC, [Disattivato] ASC)
    INCLUDE([DataModifica], [Provenienza], [IdProvenienza], [Id]) WITH (FILLFACTOR = 70);

