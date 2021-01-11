CREATE TABLE [test].[OscuramentiMassiviDaProcessare] (
    [Id]                                              UNIQUEIDENTIFIER CONSTRAINT [DF_OscuramentiMassiviDaProcessare_Id] DEFAULT (newid()) NOT NULL,
    [DataInserimento]                                 DATETIME         CONSTRAINT [DF_OscuramentiMassiviDaProcessare_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [IdOscuramento]                                   UNIQUEIDENTIFIER NOT NULL,
    [ProcessamentoRefertiStato]                       VARCHAR (16)     NOT NULL,
    [ProcessamentoRefertiIdUltimoReferto]             UNIQUEIDENTIFIER NULL,
    [ProcessamentoRefertiDataModificaUltimoReferto]   DATETIME         NULL,
    [ProcessamentoEventiStato]                        VARCHAR (16)     NOT NULL,
    [ProcessamentoEventiAziendaEroganteUltimoEvento]  VARCHAR (16)     NULL,
    [ProcessamentoEventiNumeroNosologicoUltimoEvento] VARCHAR (64)     NULL,
    [ProcessamentoEventiDataModificaUltimoEvento]     DATETIME         NULL,
    CONSTRAINT [PK_OscuramentiMassiviDaProcessare] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_OscuramentiMassiviDaProcessare_ProcessamentoEventiStato]
    ON [test].[OscuramentiMassiviDaProcessare]([ProcessamentoEventiStato] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OscuramentiMassiviDaProcessare_ProcessamentoRefertiStato]
    ON [test].[OscuramentiMassiviDaProcessare]([ProcessamentoRefertiStato] ASC);

