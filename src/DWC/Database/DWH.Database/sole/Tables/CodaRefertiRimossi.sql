CREATE TABLE [sole].[CodaRefertiRimossi] (
    [Id]            UNIQUEIDENTIFIER CONSTRAINT [DF_Sole_CodaRefertiRimossi_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataRimozione] DATETIME         CONSTRAINT [DF_Sole_CodaRefertiRimossi_DataRimozione] DEFAULT (getutcdate()) NOT NULL,
    [Record]        VARBINARY (MAX)  NULL,
    [IdReferto]     UNIQUEIDENTIFIER CONSTRAINT [DF_sole_CodaRefertiRimossi_IdReferto] DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    [Motivo]        VARCHAR (64)     NULL,
    CONSTRAINT [PK_Sole_CodaRefertiRimossi_Id] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);






GO
CREATE NONCLUSTERED INDEX [IX_IdReferto]
    ON [sole].[CodaRefertiRimossi]([IdReferto] ASC);

