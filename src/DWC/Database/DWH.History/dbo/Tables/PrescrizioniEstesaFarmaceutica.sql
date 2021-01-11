CREATE TABLE [dbo].[PrescrizioniEstesaFarmaceutica] (
    [IdPrescrizioniBase]                              UNIQUEIDENTIFIER NOT NULL,
    [DataPartizione]                                  SMALLDATETIME    NOT NULL,
    [Riga]                                            INT              NOT NULL,
    [DataInserimento]                                 DATETIME         NOT NULL,
    [DataModifica]                                    DATETIME         NOT NULL,
    [InfoGenerali_Progressivo]                        VARCHAR (250)    NULL,
    [InfoGenerali_Quantita]                           VARCHAR (20)     NULL,
    [InfoGenerali_Posologia]                          VARCHAR (200)    NULL,
    [InfoGenerali_Note]                               VARCHAR (MAX)    NULL,
    [InfoGenerali_Classe]                             VARCHAR (MAX)    NULL,
    [InfoGenerali_NotaAifa]                           VARCHAR (200)    NULL,
    [InfoGenerali_NonSostituibile]                    BIT              NULL,
    [InfoGenerali_CodMotivazioneNonSostituibile]      VARCHAR (250)    NULL,
    [Codifiche_AicSpecialita]                         VARCHAR (100)    NULL,
    [Codifiche_MinSan10Specialita]                    VARCHAR (128)    NULL,
    [Codifiche_DescSpecialita]                        VARCHAR (100)    NULL,
    [Codifiche_CodGruppoTerapeutico]                  VARCHAR (250)    NULL,
    [Codifiche_CodGruppoEquivalenza]                  VARCHAR (250)    NULL,
    [Codifiche_DescGruppoEquivalenza]                 VARCHAR (250)    NULL,
    [PercorsiRegionali_CodPercorsoRegionale]          VARCHAR (250)    NULL,
    [PercorsiRegionali_DescPercorsoRegionale]         VARCHAR (250)    NULL,
    [PercorsiRegionali_CodAziendaPercorsoRegionale]   VARCHAR (250)    NULL,
    [PercorsiRegionali_CodStrutturaPercorsoRegionale] VARCHAR (250)    NULL,
    CONSTRAINT [PK_PrescrizioniEstesaFarmaceutica] PRIMARY KEY CLUSTERED ([DataPartizione] ASC, [IdPrescrizioniBase] ASC, [Riga] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [CK_PrescrizioniEstesaFarmaceutica] CHECK ([DataPartizione]<CONVERT([smalldatetime],'20070101',(0))),
    CONSTRAINT [FK_PrescrizioniEstesaFarmaceutica_PrescrizioniEstesaTestata] FOREIGN KEY ([DataPartizione], [IdPrescrizioniBase]) REFERENCES [dbo].[PrescrizioniEstesaTestata] ([DataPartizione], [IdPrescrizioniBase]) NOT FOR REPLICATION
);




GO


