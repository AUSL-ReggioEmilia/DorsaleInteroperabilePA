CREATE TABLE [codifiche].[SOLECodifichePrestazioni] (
    [Id]                     UNIQUEIDENTIFIER CONSTRAINT [DF_CodifichePrestazioniSOLE_Id] DEFAULT (newsequentialid()) NOT NULL,
    [CodicePrestazione]      VARCHAR (16)     NOT NULL,
    [DescrizionePrestazione] VARCHAR (256)    NOT NULL,
    [CodiceDmr]              VARCHAR (16)     NULL,
    [DescrizioneDmr]         VARCHAR (512)    NULL,
    [CodiceSpecialita]       VARCHAR (16)     NULL,
    [DescrizioneSpecialita]  VARCHAR (256)    NULL,
    [Oscurato]               BIT              NOT NULL,
    [DataInizioValidita]     DATE             NULL,
    [DataFineValidita]       DATE             NULL,
    [NotaInizioValidita]     VARCHAR (512)    NULL,
    [NotaFineValidita]       VARCHAR (512)    NULL,
    [Importo]                SMALLMONEY       NULL,
    [Esenzione]              VARCHAR (16)     NULL,
    [DataInserimento]        DATETIME         CONSTRAINT [DF_CodifichePrestazioniSOLE_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]           DATETIME         CONSTRAINT [DF_CodifichePrestazioniSOLE_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento]      VARCHAR (128)    CONSTRAINT [DF_CodifichePrestazioniSOLE_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    [UtenteModifica]         VARCHAR (128)    CONSTRAINT [DF_CodifichePrestazioniSOLE_UtenteModifica] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_SOLECodifichePrestazioni] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CODICEPRESTAZIONE]
    ON [codifiche].[SOLECodifichePrestazioni]([CodicePrestazione] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CODICESPECIALITA]
    ON [codifiche].[SOLECodifichePrestazioni]([CodiceSpecialita] ASC);

