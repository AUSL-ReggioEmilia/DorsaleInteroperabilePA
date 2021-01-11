CREATE TABLE [dbo].[PrescrizioniEstesaTestata] (
    [IdPrescrizioniBase]                                             UNIQUEIDENTIFIER NOT NULL,
    [DataPartizione]                                                 SMALLDATETIME    NOT NULL,
    [TipoPrescrizione]                                               VARCHAR (32)     NOT NULL,
    [DataInserimento]                                                DATETIME         NOT NULL,
    [DataModifica]                                                   DATETIME         NOT NULL,
    [InformazioniTecniche_Promemoria]                                VARCHAR (MAX)    NULL,
    [InformazioniTecniche_MacAddressPrescrittore]                    VARCHAR (MAX)    NULL,
    [InformazioniTecniche_SwPrescrittore]                            VARCHAR (227)    NULL,
    [Medico_Titolare_CodiceFiscale]                                  VARCHAR (60)     NULL,
    [Medico_Titolare_CodRegionale]                                   VARCHAR (60)     NULL,
    [Medico_Titolare_Cognome]                                        VARCHAR (60)     NULL,
    [Medico_Titolare_Nome]                                           VARCHAR (60)     NULL,
    [Medico_Titolare_CodTipoSpecializzazione]                        VARCHAR (60)     NULL,
    [Medico_Titolare_CodRegione]                                     VARCHAR (60)     NULL,
    [Medico_Titolare_CodAzienda]                                     VARCHAR (60)     NULL,
    [Medico_Titolare_CodStruttura]                                   VARCHAR (60)     NULL,
    [Medico_Titolare_Indirizzo]                                      VARCHAR (60)     NULL,
    [Medico_Prescrittore_CodiceFiscale]                              VARCHAR (250)    NULL,
    [Medico_Prescrittore_CodRegionale]                               VARCHAR (128)    NULL,
    [Medico_Prescrittore_Cognome]                                    VARCHAR (250)    NULL,
    [Medico_Prescrittore_Nome]                                       VARCHAR (250)    NULL,
    [Medico_Prescrittore_CodTipoSpecializzazione]                    VARCHAR (250)    NULL,
    [Medico_Prescrittore_CodAzienda]                                 VARCHAR (128)    NULL,
    [Medico_Prescrittore_DescAzienda]                                VARCHAR (128)    NULL,
    [Medico_Prescrittore_Indirizzo]                                  VARCHAR (128)    NULL,
    [Paziente_DocumentiIdentita_CodiceFiscale]                       VARCHAR (20)     NULL,
    [Paziente_DocumentiIdentita_TesseraSanitaria]                    VARCHAR (128)    NULL,
    [Paziente_DocumentiIdentita_STP]                                 VARCHAR (20)     NULL,
    [Paziente_DocumentiIdentita_ENI]                                 VARCHAR (20)     NULL,
    [Paziente_DocumentiIdentita_NumeroIdPersonale]                   VARCHAR (20)     NULL,
    [Paziente_DocumentiIdentita_CodStatoEstero]                      VARCHAR (20)     NULL,
    [Paziente_DocumentiIdentita_DescStatoEstero]                     VARCHAR (128)    NULL,
    [Paziente_DocumentiIdentita_TsEuropea]                           VARCHAR (20)     NULL,
    [Paziente_DocumentiIdentita_ScandenzaTS]                         DATE             NULL,
    [Paziente_DocumentiIdentita_IstituzioneTS]                       VARCHAR (20)     NULL,
    [Paziente_DocumentiIdentita_TesseraSASN]                         VARCHAR (20)     NULL,
    [Paziente_DocumentiIdentita_CodAuslAppartenenza]                 VARCHAR (20)     NULL,
    [Paziente_DocumentiIdentita_DescAuslAppartenenza]                VARCHAR (20)     NULL,
    [Paziente_DocumentiIdentita_MatricolaCIIP]                       VARCHAR (20)     NULL,
    [Paziente_DocumentiIdentita_CodSocietaNavigazione]               VARCHAR (20)     NULL,
    [Paziente_DocumentiIdentita_DescSocietaNavigazione]              VARCHAR (20)     NULL,
    [Paziente_DatiAnagrafici_Cognome]                                VARCHAR (48)     NULL,
    [Paziente_DatiAnagrafici_Nome]                                   VARCHAR (48)     NULL,
    [Paziente_DatiAnagrafici_Sesso]                                  VARCHAR (1)      NULL,
    [Paziente_DatiAnagrafici_DataNascita]                            DATETIME         NULL,
    [Paziente_DatiAnagrafici_CodComuneNascita]                       VARCHAR (106)    NULL,
    [Paziente_DatiAnagrafici_DescComuneNascita]                      VARCHAR (106)    NULL,
    [Paziente_DatiAnagrafici_CodCittadinanza]                        VARCHAR (80)     NULL,
    [Paziente_DatiAnagrafici_DescCittadinanza]                       VARCHAR (80)     NULL,
    [Paziente_Indirizzi_IndirizzoResidenza]                          VARCHAR (106)    NULL,
    [Paziente_Indirizzi_CodComuneResidenza]                          VARCHAR (106)    NULL,
    [Paziente_Indirizzi_DescComuneResidenza]                         VARCHAR (106)    NULL,
    [Paziente_Indirizzi_CodRegioneResidenza]                         VARCHAR (106)    NULL,
    [Paziente_Indirizzi_CapResidenza]                                VARCHAR (106)    NULL,
    [Paziente_Indirizzi_ProvResidenza]                               VARCHAR (106)    NULL,
    [Paziente_Indirizzi_IndirizzoDomicilio]                          VARCHAR (106)    NULL,
    [Paziente_Indirizzi_CodComuneDomicilio]                          VARCHAR (106)    NULL,
    [Paziente_Indirizzi_DescComuneDomicilio]                         VARCHAR (106)    NULL,
    [Paziente_Indirizzi_CodRegioneDomicilio]                         VARCHAR (106)    NULL,
    [Paziente_Indirizzi_CapDomicilio]                                VARCHAR (106)    NULL,
    [Paziente_Indirizzi_ProvDomicilio]                               VARCHAR (106)    NULL,
    [Paziente_Indirizzi_Telefono]                                    VARCHAR (40)     NULL,
    [Paziente_Indirizzi_Email]                                       VARCHAR (40)     NULL,
    [Paziente_ASL_CodAslAssistenza]                                  VARCHAR (90)     NULL,
    [Paziente_ASL_DescAslAssistenza]                                 VARCHAR (90)     NULL,
    [Paziente_ASL_CodAslResidenza]                                   VARCHAR (90)     NULL,
    [Paziente_ASL_DescAslResidenza]                                  VARCHAR (90)     NULL,
    [Paziente_Altro_ConsensoFseRegionale]                            VARCHAR (MAX)    NULL,
    [Prescrizione_InformazioniGenerali_Nre]                          VARCHAR (22)     NULL,
    [Prescrizione_InformazioniGenerali_IdRegionale]                  VARCHAR (22)     NULL,
    [Prescrizione_InformazioniGenerali_TipoPrescrizione]             VARCHAR (15)     NULL,
    [Prescrizione_InformazioniGenerali_Esenzione]                    VARCHAR (MAX)    NULL,
    [Prescrizione_InformazioniGenerali_CodTipoVisita]                VARCHAR (1)      NULL,
    [Prescrizione_InformazioniGenerali_CodTipoRicetta]               VARCHAR (200)    NULL,
    [Prescrizione_InformazioniGenerali_PrescrizioneUsoInterno]       BIT              NULL,
    [Prescrizione_InformazioniGenerali_CodTipoIndicazione]           VARCHAR (250)    NULL,
    [Prescrizione_InformazioniGenerali_OscuramentoDatiAnagr]         BIT              NULL,
    [Prescrizione_InformazioniGenerali_TotaleConfezioniPrestazioni]  VARCHAR (10)     NULL,
    [Prescrizione_Note_PropostaTerapeutica]                          VARCHAR (MAX)    NULL,
    [Prescrizione_Note_CodQuesitoDiagnostico]                        VARCHAR (300)    NULL,
    [Prescrizione_Note_NoteUsoRegionale]                             VARCHAR (250)    NULL,
    [Prescrizione_Specialistiche_Priorita]                           VARCHAR (20)     NULL,
    [Prescrizione_Specialistiche_IdRegionalePrescrizioneRiferimento] VARCHAR (22)     NULL,
    [Prescrizione_Specialistiche_NrePrescrizioneRiferimento]         VARCHAR (22)     NULL,
    [Prescrizione_Specialistiche_VersioneCatalogoPrestRegionale]     VARCHAR (MAX)    NULL,
    [Prescrizione_Specialistiche_PrestFuoriCatalogoRegionale]        BIT              NULL,
    [Prescrizione_Rossa_BarCodeCF]                                   BIT              NULL,
    [Prescrizione_Farmaceutiche_VersioneProntuarioFarmRegionale]     VARCHAR (MAX)    NULL,
    [Prescrizione_Farmaceutiche_FarmaciSenzaPA]                      BIT              NULL,
    [Prescrizione_Note_DescQuesitoDiagnostico]                       VARCHAR (2048)   NULL,
    [Prescrizione_InformazioniGenerali_Data]                         VARCHAR (128)    NULL,
    CONSTRAINT [PK_PrescrizioniEstesaTestata] PRIMARY KEY CLUSTERED ([DataPartizione] ASC, [IdPrescrizioniBase] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_PrescrizioniEstesaTestata_DataPartizione] CHECK ([DataPartizione]>=CONVERT([smalldatetime],'20070101',(0))),
    CONSTRAINT [FK_PrescrizioniEstesaTestata_PrescrizioniBase] FOREIGN KEY ([DataPartizione], [IdPrescrizioniBase]) REFERENCES [dbo].[PrescrizioniBase] ([DataPartizione], [Id]) NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[PrescrizioniEstesaTestata] NOCHECK CONSTRAINT [FK_PrescrizioniEstesaTestata_PrescrizioniBase];




GO
ALTER TABLE [dbo].[PrescrizioniEstesaTestata] NOCHECK CONSTRAINT [FK_PrescrizioniEstesaTestata_PrescrizioniBase];




GO
ALTER TABLE [dbo].[PrescrizioniEstesaTestata] NOCHECK CONSTRAINT [FK_PrescrizioniEstesaTestata_PrescrizioniBase];




GO
CREATE NONCLUSTERED INDEX [IX_DataModifica_Tipo]
    ON [dbo].[PrescrizioniEstesaTestata]([DataModifica] ASC, [TipoPrescrizione] ASC) WITH (FILLFACTOR = 70);



