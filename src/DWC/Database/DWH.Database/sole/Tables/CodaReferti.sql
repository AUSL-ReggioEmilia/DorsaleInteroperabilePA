CREATE TABLE [sole].[CodaReferti] (
    [IdSequenza]           INT              IDENTITY (1, 1) NOT NULL,
    [DataInserimento]      DATETIME         CONSTRAINT [DF_Sole_CodaReferti_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
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
    CONSTRAINT [PK_CodaReferti_Id] PRIMARY KEY CLUSTERED ([IdSequenza] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [CK_Sole_CodaReferti_Sorgente] CHECK ([Sorgente]='DAE' OR [Sorgente]='Oscuramenti' OR [Sorgente]='Mnt' OR [Sorgente]='Admin')
);






GO
CREATE NONCLUSTERED INDEX [IX_Priorita_DataModifica]
    ON [sole].[CodaReferti]([Priorita] ASC, [DataModificaReferto] ASC)
    INCLUDE([IdSequenza], [OreRitardoInvio]);


GO
CREATE NONCLUSTERED INDEX [IX_IdReferto]
    ON [sole].[CodaReferti]([IdReferto] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_NumeroNosologico]
    ON [sole].[CodaReferti]([NumeroNosologico] ASC, [AziendaErogante] ASC, [SistemaErogante] ASC) WITH (FILLFACTOR = 70);

