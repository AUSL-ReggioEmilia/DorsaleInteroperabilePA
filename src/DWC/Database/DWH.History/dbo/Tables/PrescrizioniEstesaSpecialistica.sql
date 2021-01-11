CREATE TABLE [dbo].[PrescrizioniEstesaSpecialistica] (
    [IdPrescrizioniBase]                              UNIQUEIDENTIFIER NOT NULL,
    [DataPartizione]                                  SMALLDATETIME    NOT NULL,
    [Riga]                                            INT              NOT NULL,
    [DataInserimento]                                 DATETIME         NOT NULL,
    [DataModifica]                                    DATETIME         NOT NULL,
    [InfoGenerali_Progressivo]                        VARCHAR (4)      NULL,
    [InfoGenerali_Quantita]                           VARCHAR (20)     NULL,
    [InfoGenerali_Note]                               VARCHAR (256)    NULL,
    [InfoGenerali_CodBranca]                          VARCHAR (60)     NULL,
    [InfoGenerali_TipoAccesso]                        VARCHAR (128)    NULL,
    [Codifiche_CodDmRegionale]                        VARCHAR (250)    NULL,
    [Codifiche_CodCatalogoRegionale]                  VARCHAR (200)    NULL,
    [Codifiche_DescDmRegionale]                       VARCHAR (200)    NULL,
    [Codifiche_DescCatalogoRegionale]                 VARCHAR (200)    NULL,
    [Codifiche_CodAziendale]                          VARCHAR (200)    NULL,
    [Codifiche_DescAziendale]                         VARCHAR (200)    NULL,
    [PercorsiRegionali_CodPacchettoRegionale]         VARCHAR (250)    NULL,
    [PercorsiRegionali_CodPercorsoRegionale]          VARCHAR (250)    NULL,
    [PercorsiRegionali_DescPercorsoRegionale]         VARCHAR (250)    NULL,
    [PercorsiRegionali_CodAziendaPercorsoRegionale]   VARCHAR (250)    NULL,
    [PercorsiRegionali_CodStrutturaPercorsoRegionale] VARCHAR (250)    NULL,
    [Dm915_Nota]                                      VARCHAR (MAX)    NULL,
    [Dm915_Erog]                                      VARCHAR (MAX)    NULL,
    [Dm915_Appr]                                      VARCHAR (MAX)    NULL,
    [Dm915_Pat]                                       VARCHAR (128)    NULL,
    CONSTRAINT [PK_PrescrizioniEstesaSpecialistica] PRIMARY KEY CLUSTERED ([DataPartizione] ASC, [IdPrescrizioniBase] ASC, [Riga] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [CK_PrescrizioniEstesaSpecialistica] CHECK ([DataPartizione]<CONVERT([smalldatetime],'20070101',(0))),
    CONSTRAINT [FK_PrescrizioniEstesaSpecialistica_PrescrizioniEstesaTestata] FOREIGN KEY ([DataPartizione], [IdPrescrizioniBase]) REFERENCES [dbo].[PrescrizioniEstesaTestata] ([DataPartizione], [IdPrescrizioniBase]) NOT FOR REPLICATION
);




GO


