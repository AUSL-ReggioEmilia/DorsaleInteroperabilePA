CREATE TABLE [sole].[CodaRefertiInviati] (
    [Id]                   UNIQUEIDENTIFIER CONSTRAINT [DF_Sole_CodaRefertiInviati_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataInvio]            DATETIME         CONSTRAINT [DF_Sole_CodaRefertiInviati_DataInvio] DEFAULT (getutcdate()) NOT NULL,
    [IdSequenza]           INT              NOT NULL,
    [DataInserimento]      DATETIME         NOT NULL,
    [IdReferto]            UNIQUEIDENTIFIER NOT NULL,
    [Operazione]           SMALLINT         NOT NULL,
    [Sorgente]             VARCHAR (64)     NOT NULL,
    [AziendaErogante]      VARCHAR (16)     NOT NULL,
    [SistemaErogante]      VARCHAR (16)     NOT NULL,
    [StatoRichiestaCodice] TINYINT          NOT NULL,
    [DataModificaReferto]  DATETIME         NOT NULL,
    [Priorita]             INT              NOT NULL,
    [OreRitardoInvio]      INT              NOT NULL,
    [Messaggio]            VARBINARY (MAX)  NULL,
    [NumeroNosologico]     VARCHAR (64)     NULL,
    CONSTRAINT [PK_Sole_CodaRefertiInviati_Id] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);






GO
CREATE NONCLUSTERED INDEX [IX_IdReferto]
    ON [sole].[CodaRefertiInviati]([IdReferto] ASC);

