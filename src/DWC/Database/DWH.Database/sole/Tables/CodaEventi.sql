CREATE TABLE [sole].[CodaEventi] (
    [IdSequenza]         INT              IDENTITY (1, 1) NOT NULL,
    [DataInserimento]    DATETIME         CONSTRAINT [DF_Sole_CodaEventi_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
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
    [NumeroNosologico]   VARCHAR (64)     NOT NULL,
    CONSTRAINT [PK_CodaEventi_Id] PRIMARY KEY CLUSTERED ([IdSequenza] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [CK_Sole_CodaEventi_Sorgente] CHECK ([Sorgente]='DAE' OR [Sorgente]='Oscuramenti' OR [Sorgente]='Mnt' OR [Sorgente]='Admin')
);






GO
CREATE NONCLUSTERED INDEX [IX_Priorita_DataModifica]
    ON [sole].[CodaEventi]([Priorita] ASC, [DataModificaEvento] ASC)
    INCLUDE([IdSequenza], [OreRitardoInvio]);


GO
CREATE NONCLUSTERED INDEX [IX_IdEvento]
    ON [sole].[CodaEventi]([IdEvento] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_NumeroNosologico]
    ON [sole].[CodaEventi]([NumeroNosologico] ASC, [AziendaErogante] ASC, [SistemaErogante] ASC) WITH (FILLFACTOR = 70);

