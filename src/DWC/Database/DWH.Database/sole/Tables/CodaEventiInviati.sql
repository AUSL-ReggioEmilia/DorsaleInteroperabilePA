CREATE TABLE [sole].[CodaEventiInviati] (
    [Id]                 UNIQUEIDENTIFIER CONSTRAINT [DF_Sole_CodaEventiInviati_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataInvio]          DATETIME         CONSTRAINT [DF_Sole_CodaEventiInviati_DataInvio] DEFAULT (getutcdate()) NOT NULL,
    [IdSequenza]         INT              NOT NULL,
    [DataInserimento]    DATETIME         NOT NULL,
    [IdEvento]           UNIQUEIDENTIFIER NOT NULL,
    [Operazione]         SMALLINT         NOT NULL,
    [Sorgente]           VARCHAR (64)     NOT NULL,
    [AziendaErogante]    VARCHAR (16)     NOT NULL,
    [SistemaErogante]    VARCHAR (16)     NOT NULL,
    [TipoEventoCodice]   VARCHAR (16)     NOT NULL,
    [TipoRicoveroCodice] VARCHAR (16)     NOT NULL,
    [DataModificaEvento] DATETIME         NOT NULL,
    [Priorita]           INT              NOT NULL,
    [OreRitardoInvio]    INT              NOT NULL,
    [Messaggio]          VARBINARY (MAX)  NULL,
    [NumeroNosologico]   VARCHAR (64)     CONSTRAINT [DF_CodaEventiInviati_NumeroNosologico] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_Sole_CodaEventiInviati_Id] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);






GO
CREATE NONCLUSTERED INDEX [IX_IdEvento]
    ON [sole].[CodaEventiInviati]([IdEvento] ASC);

