CREATE TABLE [sole].[CodaEventiRimossi] (
    [Id]            UNIQUEIDENTIFIER CONSTRAINT [DF_Sole_CodaEventiRimossi_Id] DEFAULT (newsequentialid()) NOT NULL,
    [DataRimozione] DATETIME         CONSTRAINT [DF_Sole_CodaEventiRimossi_DataRimozione] DEFAULT (getutcdate()) NOT NULL,
    [Record]        VARBINARY (MAX)  NULL,
    [IdEvento]      UNIQUEIDENTIFIER CONSTRAINT [DF_sole_CodaEventiRimossi_IdEvento] DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    [Motivo]        VARCHAR (64)     NULL,
    CONSTRAINT [PK_Sole_CodaEventiRimossi_Id] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);






GO
CREATE NONCLUSTERED INDEX [IX_IdEvento]
    ON [sole].[CodaEventiRimossi]([IdEvento] ASC);

