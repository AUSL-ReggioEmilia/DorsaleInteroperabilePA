CREATE TABLE [dbo].[CodaPrescrizioniOutputInviati] (
    [Id]                  UNIQUEIDENTIFIER CONSTRAINT [DF_CodaPrescrizioniOutputInviati_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataInvio]           DATETIME         CONSTRAINT [DF_CodaPrescrizioniOutputInviati_DataInvio] DEFAULT (getutcdate()) NOT NULL,
    [IdSequenza]          INT              NOT NULL,
    [DataInserimento]     DATETIME         NOT NULL,
    [IdPrescrizione]      UNIQUEIDENTIFIER NOT NULL,
    [Operazione]          SMALLINT         NOT NULL,
    [IdCorrelazione]      VARCHAR (64)     NOT NULL,
    [CorrelazioneTimeout] INT              NOT NULL,
    [OrdineInvio]         SMALLINT         NOT NULL,
    [MessaggioCompresso]  VARBINARY (MAX)  NULL,
    CONSTRAINT [PK_CodaPrescrizioniOutputInviati_Id] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [IX_IdReferto]
    ON [dbo].[CodaPrescrizioniOutputInviati]([IdPrescrizione] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_DataInvio]
    ON [dbo].[CodaPrescrizioniOutputInviati]([DataInvio] ASC, [DataInserimento] ASC)
    INCLUDE([IdPrescrizione], [Operazione]);

